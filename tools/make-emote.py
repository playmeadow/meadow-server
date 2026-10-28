"""make-emote.py <picture.png> [name] [--slot=N] [--black-background]

Adds an emote of our own to swf/HUDAssets.swf, from a picture: the classes
"<name>" (the emote over an animal's head and in a chat bubble) and
"<name>_sml" (the small one in the emote picker and in chat lines), each a
clip holding the picture, the size and place the game's own emotes have.
The default name is emo_temp, the face with a thermometer.

The game makes an emote by its class name (gui.EmoticonUtility), so the
name also has to be in that class's lists: swf-src/EmoticonUtility.cinit.pcode,
which tools/build-client.sh puts into the client.

Each emote of ours has a slot (--slot=N, 0 by default: emo_temp's), its
own character ids and its own code: running it again for a slot replaces
what an earlier run put there, and leaves the other slots as they are. The picture must be an
8-bit RGBA PNG, not interlaced; --black-background is for one that came on
black where it should be see-through. Needs nothing but Python.
"""
import lzma
import struct
import sys
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HUD = ROOT / "swf" / "HUDAssets.swf"

# character ids of ours, far above the file's own (which end near 4,000):
# picture, the two shapes, the two clips.
FIRST_ID = 60001
ABC_NAME = b"ours_emote"
# the game's emotes are drawn about their middle: the large ones 35 by 38
# pixels (emo_sick's shape is 706 by 763 twips), the small ones 19 by 20.
LARGE_WIDTH = 706
SMALL_WIDTH = 373
SHRINK = 2  # the picture is kept at half its size, which is still four times the large emote


def read_png(path):
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        sys.exit("not a PNG")
    pos, idat, head = 8, b"", None
    while pos < len(data):
        length, kind = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + length]
        if kind == b"IHDR":
            head = struct.unpack(">IIBBBBB", body)
        elif kind == b"IDAT":
            idat += body
        pos += 12 + length
    width, height, depth, colour, _, _, interlace = head
    if (depth, colour, interlace) != (8, 6, 0):
        sys.exit("the picture must be 8-bit RGBA and not interlaced")
    raw = zlib.decompress(idat)
    stride = width * 4
    rows, previous = [], bytearray(stride)
    for y in range(height):
        kind = raw[y * (stride + 1)]
        line = bytearray(raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)])
        for i in range(stride):
            left = line[i - 4] if i >= 4 else 0
            up = previous[i]
            corner = previous[i - 4] if i >= 4 else 0
            if kind == 1:
                line[i] = (line[i] + left) & 255
            elif kind == 2:
                line[i] = (line[i] + up) & 255
            elif kind == 3:
                line[i] = (line[i] + (left + up) // 2) & 255
            elif kind == 4:
                estimate = left + up - corner
                nearest = min((abs(estimate - left), 0, left), (abs(estimate - up), 1, up), (abs(estimate - corner), 2, corner))[2]
                line[i] = (line[i] + nearest) & 255
        rows.append(line)
        previous = line
    return width, height, rows


def without_background(width, height, rows, darkest=28):
    """Makes the black around the drawing see-through: every pixel that
    dark which can be reached from the picture's edge. Black inside the
    drawing (eyes, a mouth) is not reached and stays."""
    dark = lambda x, y: max(rows[y][x * 4:x * 4 + 3]) <= darkest and rows[y][x * 4 + 3] != 0
    todo = [(x, y) for x in range(width) for y in (0, height - 1)] + [(x, y) for y in range(height) for x in (0, width - 1)]
    while todo:
        x, y = todo.pop()
        if 0 <= x < width and 0 <= y < height and dark(x, y):
            rows[y][x * 4 + 3] = 0
            todo += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return width, height, rows


def shrunk(width, height, rows, by):
    """The picture at 1/by of its size, as SWF wants it: ARGB with the
    colours already multiplied by the alpha."""
    out_width, out_height = width // by, height // by
    out = bytearray()
    for y in range(out_height):
        for x in range(out_width):
            red = green = blue = alpha = 0
            for dy in range(by):
                line = rows[y * by + dy]
                for dx in range(by):
                    i = (x * by + dx) * 4
                    a = line[i + 3]
                    red += line[i] * a
                    green += line[i + 1] * a
                    blue += line[i + 2] * a
                    alpha += a
            count = by * by
            out += bytes((alpha // count, red // (255 * count), green // (255 * count), blue // (255 * count)))
    return out_width, out_height, bytes(out)


class Bits:
    def __init__(self):
        self.bits = []

    def unsigned(self, value, count):
        self.bits += [(value >> (count - 1 - i)) & 1 for i in range(count)]

    def signed(self, value, count):
        self.unsigned(value & ((1 << count) - 1), count)

    def bytes(self):
        bits = self.bits + [0] * (-len(self.bits) % 8)
        return bytes(sum(bit << (7 - i) for i, bit in enumerate(bits[n:n + 8])) for n in range(0, len(bits), 8))


def needed(*values):
    """Bits for the widest of these signed numbers."""
    return max(max(abs(value) for value in values).bit_length() + 1, 2)


def rect(x1, x2, y1, y2):
    bits = Bits()
    count = needed(x1, x2, y1, y2)
    bits.unsigned(count, 5)
    for value in (x1, x2, y1, y2):
        bits.signed(value, count)
    return bits.bytes()


def tag(code, body):
    if len(body) < 63 and code not in (2, 36, 39):
        return struct.pack("<H", code << 6 | len(body)) + body
    return struct.pack("<HI", code << 6 | 63, len(body)) + body


def picture_shape(shape_id, bitmap_id, pixels_wide, pixels_high, width):
    """A rectangle filled with the picture, `width` twips across and with
    its middle at 0,0."""
    height = round(width * pixels_high / pixels_wide)
    left, top = -(width // 2), -(height // 2)
    right, bottom = left + width, top + height
    bits = Bits()
    # the fill's matrix: twips per pixel of the picture, as 16.16, and where
    # the picture's corner goes.
    scale = round(width / pixels_wide * 65536)
    bits.unsigned(1, 1)
    bits.unsigned(needed(scale), 5)
    bits.signed(scale, needed(scale))
    bits.signed(scale, needed(scale))
    bits.unsigned(0, 1)
    count = needed(left, top)
    bits.unsigned(count, 5)
    bits.signed(left, count)
    bits.signed(top, count)
    matrix = bits.bytes()
    # one fill style: 0x41, a picture drawn once and smoothed. no lines.
    styles = bytes([1, 0x41]) + struct.pack("<H", bitmap_id) + matrix + bytes([0])
    bits = Bits()
    bits.unsigned(1, 4)  # bits in a fill number
    bits.unsigned(0, 4)  # ... and a line number
    # go to the corner, with the fill on the right-hand side.
    bits.unsigned(0, 1)
    bits.unsigned(0b00101, 5)  # fill style 1 and a move
    count = needed(left, top)
    bits.unsigned(count, 5)
    bits.signed(left, count)
    bits.signed(top, count)
    bits.unsigned(1, 1)
    for dx, dy in ((width, 0), (0, height), (-width, 0), (0, -height)):
        length = needed(dx, dy)
        bits.unsigned(1, 1)
        bits.unsigned(1, 1)  # a straight edge
        bits.unsigned(length - 2, 4)
        bits.unsigned(0, 1)  # along one axis only
        bits.unsigned(1 if dx == 0 else 0, 1)
        bits.signed(dy if dx == 0 else dx, length)
    bits.unsigned(0, 6)
    return tag(2, struct.pack("<H", shape_id) + rect(left, right, top, bottom) + styles + bits.bytes())


def clip(sprite_id, shape_id):
    place = tag(26, bytes([0x06]) + struct.pack("<HH", 1, shape_id) + bytes([0]))  # the shape at depth 1, where it is
    return tag(39, struct.pack("<HH", sprite_id, 1) + place + tag(1, b"") + tag(0, b""))


def abc(names):
    """A class for each name, each `extends flash.display.MovieClip` and
    nothing else: what Flash writes for a library symbol with a class."""
    strings = ["", *names, "flash.display", "MovieClip", "Object", "flash.events", "EventDispatcher", "DisplayObject", "InteractiveObject",
               "DisplayObjectContainer", "Sprite"]
    at = {text: index + 1 for index, text in enumerate(strings)}
    out = bytearray(struct.pack("<HH", 16, 46))
    out += bytes([0, 0, 0])  # no integers, unsigned integers or doubles
    out.append(len(strings) + 1)
    for text in strings:
        out += bytes([len(text)]) + text.encode()
    # namespaces: 1 the top level, 2 flash.display, 3 flash.events (0x16 is a package).
    out += bytes([4, 0x16, at[""], 0x16, at["flash.display"], 0x16, at["flash.events"]])
    out.append(0)  # no namespace sets
    chain = [(1, "Object"), (3, "EventDispatcher"), (2, "DisplayObject"), (2, "InteractiveObject"), (2, "DisplayObjectContainer"), (2, "Sprite"),
             (2, "MovieClip")]
    qnames = [(1, name) for name in names] + chain
    multiname = {name: index + 1 for index, (_, name) in enumerate(qnames)}
    out.append(len(qnames) + 1)
    for namespace, name in qnames:
        out += bytes([0x07, namespace, at[name]])
    # for each class its static initialiser, its constructor and the
    # script that defines it; none takes or returns anything.
    count = len(names)
    out.append(count * 3)
    out += bytes([0, 0, 0, 0]) * (count * 3)
    out.append(0)  # no metadata
    out.append(count)
    for index, name in enumerate(names):
        out += bytes([multiname[name], multiname["MovieClip"], 0, 0, index * 3 + 1, 0])  # dynamic, no interfaces, no traits
    for index in range(count):
        out += bytes([index * 3, 0])
    out.append(count)
    for index, name in enumerate(names):
        out += bytes([index * 3 + 2, 1, multiname[name], 0x04, 1, index])  # one trait: the class
    bodies = []
    for index, name in enumerate(names):
        bodies.append((index * 3, 1, 9, 10, bytes([0xD0, 0x30, 0x47])))
        bodies.append((index * 3 + 1, 1, 10, 11, bytes([0xD0, 0x30, 0xD0, 0x49, 0x00, 0x47])))  # super()
        code = bytearray([0xD0, 0x30, 0x65, 0x00])
        for _, parent in chain:
            code += bytes([0x60, multiname[parent], 0x30])  # each class it comes from, onto the scope
        code += bytes([0x60, multiname["MovieClip"], 0x58, index])
        code += bytes([0x1D] * len(chain))
        code += bytes([0x68, multiname[name], 0x47])
        bodies.append((index * 3 + 2, 2, 1, 2 + len(chain), bytes(code)))
    out.append(len(bodies))
    for method, stack, scope, max_scope, code in bodies:
        out += bytes([method, stack, 1, scope, max_scope, len(code)]) + code + bytes([0, 0])
    return bytes(out)


def split(body):
    """The header of an unpacked SWF's body, then its tags as (code, bytes)."""
    header = (5 + 4 * (body[0] >> 3) + 7) // 8 + 4
    tags, pos = [], header
    while pos < len(body):
        short = struct.unpack_from("<H", body, pos)[0]
        length, start = short & 63, pos + 2
        if length == 63:
            length, start = struct.unpack_from("<I", body, pos + 2)[0], pos + 6
        tags.append((short >> 6, body[pos:start + length], body[start:start + length]))
        pos = start + length
    return body[:header], tags


def main():
    if not [word for word in sys.argv[1:] if not word.startswith("--")]:
        sys.exit(__doc__)
    words = [word for word in sys.argv[1:] if not word.startswith("--")]
    name = words[1] if len(words) > 1 else "emo_temp"
    slots = [word for word in sys.argv[1:] if word.startswith("--slot=")]
    slot = int(slots[0].split("=", 1)[1]) if slots else 0
    first_id = FIRST_ID + slot * 5
    # slot 0 keeps the name it always had, so that a run for it replaces it
    abc_name = ABC_NAME if slot == 0 else ABC_NAME + b"_" + str(slot).encode()
    picture = read_png(Path(words[0]))
    if "--black-background" in sys.argv:
        picture = without_background(*picture)
    width, height, pixels = shrunk(*picture, SHRINK)
    bitmap, large_shape, small_shape, large, small = range(first_id, first_id + 5)
    ours = [
        tag(36, struct.pack("<HBHH", bitmap, 5, width, height) + zlib.compress(pixels, 9)),
        picture_shape(large_shape, bitmap, width, height, LARGE_WIDTH),
        picture_shape(small_shape, bitmap, width, height, SMALL_WIDTH),
        clip(large, large_shape),
        clip(small, small_shape),
        tag(82, struct.pack("<I", 1) + abc_name + b"\0" + abc([name, f"{name}_sml"])),
        tag(76, struct.pack("<H", 2) + struct.pack("<H", large) + name.encode() + b"\0" + struct.pack("<H", small) + f"{name}_sml".encode() + b"\0"),
    ]

    packed = HUD.read_bytes()
    kind, version = packed[:3], packed[3]
    if kind == b"ZWS":
        filters = [lzma._decode_filter_properties(lzma.FILTER_LZMA1, packed[12:17])]
        body = lzma.LZMADecompressor(format=lzma.FORMAT_RAW, filters=filters).decompress(packed[17:], struct.unpack("<I", packed[4:8])[0] - 8)
    elif kind == b"CWS":
        body = zlib.decompress(packed[8:])
    else:
        body = packed[8:]
    header, tags = split(body)

    def is_ours(code, whole, inner):
        if code in (2, 36, 39):
            return first_id <= struct.unpack_from("<H", inner)[0] < first_id + 5
        if code == 82:
            return inner[4:4 + len(abc_name) + 1] == abc_name + b"\0"
        return code == 76 and struct.unpack_from("<H", inner, 2)[0] == large
    kept = [entry for entry in tags if not is_ours(*entry)]
    first_frame = next(index for index, (code, _, _) in enumerate(kept) if code == 1)
    out = header + b"".join(whole for _, whole, _ in kept[:first_frame]) + b"".join(ours) + b"".join(whole for _, whole, _ in kept[first_frame:])
    HUD.write_bytes(b"CWS" + bytes([version]) + struct.pack("<I", len(out) + 8) + zlib.compress(out, 9))
    print(f"{name}: a {width} by {height} picture, {len(tags) - len(kept)} old tags of ours taken out, {len(ours)} put in; {HUD.name} is {HUD.stat().st_size} bytes")


main()
