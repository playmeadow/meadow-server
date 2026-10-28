#!/usr/bin/env python3
"""Makes the pictures of the badges the admin gives (lib/badges.js), both
forms of each from one outline:

  swf/badges/<id>.swf     the name tag badge: the outline alone, in grey,
                          which the name tag tints with its own colour
  public/badges/<id>.png  the badge on player cards: the outline in white on
                          a round disc of the badge's colour

  python3 tools/make-badges.py <workdir>

Needs Java, for tools/ffdec, and nothing else. The workdir gets the files
in between and sheet.png, every badge at a size to look at.

A name tag badge is a small media file: an unseen square to point at
("iconBA") and one shape. This takes the game's star badge (media 700,
from cache/), swaps the star's outline for another and names the symbol
after it.

An outline is a list of closed paths of straight edges, drawn below in any
units with y downwards; each is a solid piece or a hole in one. Paths must
not cross or overlap each other.
"""
import hashlib
import math
import os
import re
import struct
import subprocess
import sys
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
FFDEC = os.path.join(HERE, "ffdec", "ffdec-cli.jar")
DEPLOY_VERSION = "1830"
STAR = "700"
TAG_HALF = 6.0  # how far a name tag badge reaches from its middle, in pixels: 80% of the star's 7.5
CARD_SIZE = 48  # the card's picture, drawn at a third of this
CARD_HALF = 12.5  # how far the outline reaches from the middle of that


def hashed(name):
    """LoaderCache.hashItV2, as in lib/cdn.js."""
    salted = "W3 7r4Ck h4X0r3rs" + name
    out = ""
    for index, char in enumerate(salted):
        out = out + char if index % 2 == 0 else char + out
    return hashlib.md5(out.encode()).hexdigest()


def arc(cx, cy, radius, start, end, steps):
    """Points along a circle, angles in degrees, y downwards."""
    return [(cx + radius * math.cos(math.radians(start + (end - start) * step / steps)),
             cy + radius * math.sin(math.radians(start + (end - start) * step / steps))) for step in range(steps + 1)]


def circle(cx, cy, radius, steps=16):
    return arc(cx, cy, radius, 0, 360, steps)[:-1]


def curve(start, control, end, steps):
    """Points along a quadratic curve, without its start."""
    points = []
    for step in range(1, steps + 1):
        t = step / steps
        points.append(tuple((1 - t) ** 2 * a + 2 * (1 - t) * t * b + t ** 2 * c for a, b, c in zip(start, control, end)))
    return points


def mirrored(points):
    return [(-x, y) for x, y in reversed(points)]


def turned(points, degrees):
    turn = math.radians(degrees)
    return [(x * math.cos(turn) - y * math.sin(turn), x * math.sin(turn) + y * math.cos(turn)) for x, y in points]


def bar(x1, y1, x2, y2, width):
    """A straight stroke from one point to another."""
    length = math.hypot(x2 - x1, y2 - y1)
    nx, ny = -(y2 - y1) / length * width / 2, (x2 - x1) / length * width / 2
    return [(x1 + nx, y1 + ny), (x2 + nx, y2 + ny), (x2 - nx, y2 - ny), (x1 - nx, y1 - ny)]


# each returns [(points, is_hole), ...].

def crown():
    return [([(-6.4, 5.6), (-7.5, -3.6), (-3.4, 0.2), (0, -6), (3.4, 0.2), (7.5, -3.6), (6.4, 5.6)], False)]


def shield():
    right = [(0, -7.2), (6.2, -5), (6.2, 0.5)] + curve((6.2, 0.5), (6, 5), (0, 7.4), 6)
    return [(right + [(-x, y) for x, y in reversed(right[1:-1])], False)]


def wrench():
    # an open-ended spanner standing upright, then turned: a round head
    # with a slot in the top, and a handle with a round end.
    head, slot, grip = 4.3, 1.7, 1.75
    reach = math.degrees(math.asin(slot / head))  # where the slot's sides meet the head's edge
    join = math.degrees(math.asin(grip / head))
    points = [(-slot, -4.2)]
    points += arc(0, -4, head, 270 - reach, 90 + join, 10)
    points += arc(0, 7.2, grip, 180, 0, 6)
    points += arc(0, -4, head, 90 - join, -90 + reach, 10)
    points += [(slot, -4.2)]
    return [(turned(points, 45), False)]


def brackets():
    # "</>"
    left = [(-3.4, -5.4), (-8.4, 0), (-3.4, 5.4), (-3.4, 2.6), (-5.8, 0), (-3.4, -2.6)]
    return [(left, False), (mirrored(left), False), ([(0.5, -6.4), (2.3, -6.4), (-0.5, 6.4), (-2.3, 6.4)], False)]


def brush():
    handle = [(-1.2, -9), (1.2, -9), (1.5, 0.4), (2.1, 0.4), (2.1, 3), (-2.1, 3), (-2.1, 0.4), (-1.5, 0.4)]
    tip = [(-2.1, 3.9), (2.1, 3.9)] + curve((2.1, 3.9), (3, 7), (0, 9.4), 5) + curve((0, 9.4), (-3, 7), (-2.1, 3.9), 5)[:-1]
    return [(turned(handle, 40), False), (turned(tip, 40), False)]


def question():
    cx, cy, outer, inner = 0, -3.4, 4.6, 2.2
    hook = arc(cx, cy, outer, 180, 405, 14) + [(1.2, 1.2), (1.2, 3.2), (-1.2, 3.2), (-1.2, 0.2)] + arc(cx, cy, inner, 405, 180, 12)
    return [(hook, False), (circle(0, 6.3, 1.5, 10), False)]


def bug():
    body = [(x, 1.2 + y) for x, y in zip([4.2 * math.cos(math.radians(a)) for a in range(0, 360, 20)],
                                         [5.4 * math.sin(math.radians(a)) for a in range(0, 360, 20)])]
    head = arc(0, -4.9, 2.7, 180, 360, 8)
    legs = [bar(4.9, -0.8, 7.9, -2.8, 1.4), bar(5.2, 1.6, 8.3, 1.6, 1.4), bar(4.9, 4, 7.9, 6, 1.4)]
    feelers = [bar(1.4, -7.8, 3.2, -9.6, 1.2)]
    pieces = [body, head] + legs + [mirrored(leg) for leg in legs] + feelers + [mirrored(feeler) for feeler in feelers]
    return [(piece, False) for piece in pieces]


def trophy():
    right = [(0, -7), (4.6, -7), (4.6, -3.4)] + curve((4.6, -3.4), (4.4, 1.2), (1.2, 2.4), 5) + [(1.2, 4.4), (3.8, 4.4), (3.8, 7), (0, 7)]
    cup = right + [(-x, y) for x, y in reversed(right[1:-1])]
    handle = arc(5.5, -4.2, 2.6, -90, 90, 8) + arc(5.5, -4.2, 1.3, 90, -90, 6)
    return [(cup, False), (handle, False), (mirrored(handle), False)]


def flask():
    glass = [(-2.6, -7.6), (2.6, -7.6), (2.6, -6.2), (1.7, -6.2), (1.7, -1.8), (6.4, 5.8), (5.4, 7.6), (-5.4, 7.6), (-6.4, 5.8),
             (-1.7, -1.8), (-1.7, -6.2), (-2.6, -6.2)]
    return [(glass, False), (circle(1.2, 3.4, 1.4, 10), True), (circle(-2, 5.2, 0.9, 8), True)]


def smiley():
    smile = arc(0, -0.6, 5.2, 20, 160, 10) + arc(0, -0.6, 3.6, 160, 20, 8)
    return [(circle(0, 0, 7.5, 28), False), (circle(-2.7, -2.4, 1.25, 10), True), (circle(2.7, -2.4, 1.25, 10), True), (smile, True)]


def heart_points(scale, dy=0.0):
    right = [(0, -3.2)] + curve((0, -3.2), (1.2, -6.8), (4.4, -6.6), 5) + curve((4.4, -6.6), (7.8, -6.2), (7.4, -2.2), 5) \
        + curve((7.4, -2.2), (6.8, 2.4), (0, 7.2), 7)
    points = right + [(-x, y) for x, y in reversed(right[1:-1])]
    return [(x * scale, y * scale + dy) for x, y in points]


def heart():
    # an outlined heart: the game has a solid one among its own badges.
    return [(heart_points(1), False), (heart_points(0.5, -0.2), True)]


def tick():
    return [([(-7.4, 0.6), (-4.8, -2.2), (-2, 0.8), (5, -6.4), (7.6, -3.8), (-2, 6.2)], False)]


def sprout():
    stem = [(-0.8, 2.3), (0.8, 2.3), (0.8, 8), (-0.8, 8)]
    small = [(-0.4, 1.7)] + curve((-0.4, 1.7), (-1.4, -4.4), (-7.4, -3.6), 7) + curve((-7.4, -3.6), (-6.6, 1.9), (-0.4, 1.7), 7)[:-1]
    large = [(0.4, 1.7)] + curve((0.4, 1.7), (7.6, 1.6), (7.8, -7.6), 8) + curve((7.8, -7.6), (0, -7.4), (0.4, 1.7), 8)[:-1]
    return [(stem, False), (small, False), (large, False)]


def seal_points():
    """A round seal with eight soft scallops, as verified accounts have."""
    steps = 96
    return [(7.5 * (1 + 0.075 * math.cos(math.radians(8 * angle))) * math.cos(math.radians(angle)),
             7.5 * (1 + 0.075 * math.cos(math.radians(8 * angle))) * math.sin(math.radians(angle)))
            for angle in (360 * step / steps - 90 for step in range(steps))]


def seal_tick():
    return [(x * 0.52, y * 0.52 + 0.3) for x, y in tick()[0][0]]


def verified():
    # the seal with the tick cut out of it, so the name tag's colour shows
    # the seal and the tag behind shows through the tick.
    return [(seal_points(), False), (seal_tick(), True)]


# id, outline, and the card disc's colours: top, bottom, rim. a badge whose
# rim is None has no disc: its outline's solid pieces are shaded instead,
# and its holes are white (the verified seal, blue with a white tick).
BADGES = [
    ("verified", verified, "#4cb3ff", "#1478e6", None),
    ("owner", crown, "#ffd95a", "#f0a11c", "#96600a"),
    ("moderator", shield, "#5cb2ff", "#1f6fd6", "#12458a"),
    ("contributor", wrench, "#6fd878", "#2f9e3a", "#19621f"),
    ("developer", brackets, "#8a9ab0", "#4d5b70", "#283241"),
    ("artist", brush, "#ffa066", "#ea6524", "#8f3a10"),
    ("helper", question, "#5fd9cf", "#1fa398", "#0f615a"),
    ("bughunter", bug, "#f77873", "#d03b36", "#7f1c19"),
    ("eventwinner", trophy, "#d9a273", "#9c5f2a", "#5e3613"),
    ("tester", flask, "#c6e45e", "#8fb81f", "#55700d"),
    ("friend", smiley, "#7fd6ff", "#2ba6e0", "#136a94"),
    ("supporter", heart, "#ff8fa8", "#e8476d", "#93203c"),
    ("partner", tick, "#b28cff", "#7a4fe0", "#44288f"),
    ("early", sprout, "#58b874", "#1f7a3d", "#0f4a22"),
]


def fitted(paths, half):
    """Centred, and reaching `half` from the middle."""
    xs = [x for points, _ in paths for x, _ in points]
    ys = [y for points, _ in paths for _, y in points]
    cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
    scale = half / max(max(xs) - cx, max(ys) - cy)
    return [([((x - cx) * scale, (y - cy) * scale) for x, y in points], hole) for points, hole in paths]


def area(points):
    return sum(x1 * y2 - x2 * y1 for (x1, y1), (x2, y2) in zip(points, points[1:] + points[:1]))


def records(paths, clockwise):
    """The outline as SWF shape records, in twips. A solid piece goes round
    the way the star does and a hole the other way, which puts the fill on
    the same side of every edge."""
    out, xs, ys = [], [], []
    for points, hole in fitted(paths, TAG_HALF):
        twips = [(round(x * 20), round(y * 20)) for x, y in points]
        if (area(twips) > 0) != (clockwise != hole):
            twips.reverse()
        out.append('<item type="StyleChangeRecord" fillStyle1="1" moveBits="15" moveDeltaX="%d" moveDeltaY="%d" stateFillStyle0="false" '
                   'stateFillStyle1="true" stateLineStyle="false" stateMoveTo="true" stateNewStyles="false"/>' % twips[0])
        for (x1, y1), (x2, y2) in zip(twips, twips[1:] + twips[:1]):
            if (x1, y1) != (x2, y2):
                out.append('<item type="StraightEdgeRecord" deltaX="%d" deltaY="%d" generalLineFlag="true" numBits="13" vertLineFlag="false"/>'
                           % (x2 - x1, y2 - y1))
        xs += [x for x, _ in twips]
        ys += [y for _, y in twips]
    out.append('<item type="EndShapeRecord" endOfShape="0"/>')
    bounds = '<shapeBounds type="RECT" Xmax="%d" Xmin="%d" Ymax="%d" Ymin="%d" nbits="15"/>' % (max(xs), min(xs), max(ys), min(ys))
    return bounds, "\n".join(out)


def star_points(shape):
    """The star's own outline, to learn which way round it goes."""
    move = re.search(r'moveDeltaX="(-?\d+)" moveDeltaY="(-?\d+)"', shape)
    x, y = int(move.group(1)), int(move.group(2))
    points = [(x, y)]
    for edge in re.findall(r'<item type="StraightEdgeRecord"[^>]*>', shape):
        dx, dy = re.search(r'deltaX="(-?\d+)"', edge), re.search(r'deltaY="(-?\d+)"', edge)
        x, y = x + (int(dx.group(1)) if dx else 0), y + (int(dy.group(1)) if dy else 0)
        points.append((x, y))
    return points[:-1]


def inside(paths, x, y):
    """Is the point in the outline? An odd number of crossings is in, which
    makes a hole of a path inside another."""
    crossings = 0
    for points, _ in paths:
        for (x1, y1), (x2, y2) in zip(points, points[1:] + points[:1]):
            if (y1 > y) != (y2 > y) and x < x1 + (y - y1) * (x2 - x1) / (y2 - y1):
                crossings += 1
    return crossings % 2 == 1


def rgb(colour):
    return tuple(int(colour[i:i + 2], 16) for i in (1, 3, 5))


def card_pixels(paths, top, bottom, rim):
    """CARD_SIZE square of (r, g, b, a): a disc shaded from `top` to
    `bottom` with a `rim`, the outline in white on it. Sixteen samples to a
    pixel."""
    if rim is None:
        return shape_pixels(paths, top, bottom)
    paths = fitted(paths, CARD_HALF)
    top, bottom, rim = rgb(top), rgb(bottom), rgb(rim)
    middle, fill_radius, rim_radius = CARD_SIZE / 2, 20.0, 23.0
    rows = []
    for py in range(CARD_SIZE):
        row = []
        for px in range(CARD_SIZE):
            total = [0.0, 0.0, 0.0, 0.0]
            for sy in range(4):
                for sx in range(4):
                    x, y = px + (sx + 0.5) / 4 - middle, py + (sy + 0.5) / 4 - middle
                    distance = math.hypot(x, y)
                    if distance > rim_radius:
                        continue
                    if distance > fill_radius:
                        colour = rim
                    elif inside(paths, x, y):
                        colour = (255, 255, 255)
                    else:
                        shade = (y + fill_radius) / (2 * fill_radius)
                        colour = tuple(a + (b - a) * shade for a, b in zip(top, bottom))
                    for channel in range(3):
                        total[channel] += colour[channel]
                    total[3] += 1
            row.append(tuple(round(total[c] / total[3]) if total[3] else 0 for c in range(3)) + (round(total[3] / 16 * 255),))
        rows.append(row)
    return rows


def shape_pixels(paths, top, bottom):
    """CARD_SIZE square of (r, g, b, a): the outline's solid pieces, as big
    as the disc, shaded from `top` to `bottom`, and its holes in white."""
    paths = fitted(paths, 23.0)
    solid = [(points, False) for points, hole in paths if not hole]
    holes = [(points, False) for points, hole in paths if hole]
    top, bottom = rgb(top), rgb(bottom)
    middle = CARD_SIZE / 2
    rows = []
    for py in range(CARD_SIZE):
        row = []
        for px in range(CARD_SIZE):
            total = [0.0, 0.0, 0.0, 0.0]
            for sy in range(4):
                for sx in range(4):
                    x, y = px + (sx + 0.5) / 4 - middle, py + (sy + 0.5) / 4 - middle
                    if not inside(solid, x, y):
                        continue
                    if inside(holes, x, y):
                        colour = (255, 255, 255)
                    else:
                        shade = (y + 23.0) / 46.0
                        colour = tuple(a + (b - a) * shade for a, b in zip(top, bottom))
                    for channel in range(3):
                        total[channel] += colour[channel]
                    total[3] += 1
            row.append(tuple(round(total[c] / total[3]) if total[3] else 0 for c in range(3)) + (round(total[3] / 16 * 255),))
        rows.append(row)
    return rows


def png(rows):
    raw = b"".join(b"\x00" + bytes(value for pixel in row for value in pixel) for row in rows)

    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", len(rows[0]), len(rows), 8, 6, 0, 0, 0)) \
        + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def sheet(cards, outlines):
    """Every badge to look at: the card picture, the same at the size the
    card draws it, and the name tag outline on a tag-like colour."""
    cell, small = CARD_SIZE + 4, CARD_SIZE // 3
    backgrounds = [(119, 119, 119), (233, 228, 212), (43, 43, 51), (242, 201, 76)]
    rows = [[backgrounds[(y // cell) % 4] + (255,) for _ in range(cell * len(cards))] for y in range(cell * 4)]

    def put(x0, y0, pixels):
        for dy, row in enumerate(pixels):
            for dx, (r, g, b, a) in enumerate(row):
                under = rows[y0 + dy][x0 + dx]
                rows[y0 + dy][x0 + dx] = tuple(round((c * a + u * (255 - a)) / 255) for c, u in zip((r, g, b), under)) + (255,)
    for index, (card, paths) in enumerate(zip(cards, outlines)):
        put(index * cell + 2, 2, card)
        shrunk = [[tuple(round(sum(card[y * 3 + j][x * 3 + i][c] * card[y * 3 + j][x * 3 + i][3] for j in range(3) for i in range(3))
                               / max(1, sum(card[y * 3 + j][x * 3 + i][3] for j in range(3) for i in range(3)))) for c in range(3))
                   + (round(sum(card[y * 3 + j][x * 3 + i][3] for j in range(3) for i in range(3)) / 9),)
                   for x in range(small)] for y in range(small)]
        put(index * cell + 2 + small, cell + small, shrunk)
        put(index * cell + 2 + small, cell * 3 + small, shrunk)
        # the name tag outline, three times its size, in a light tint.
        big = fitted(paths, TAG_HALF * 3)
        tag = [[(250, 240, 200, 255 if inside(big, x + 0.5 - cell / 2, y + 0.5 - cell / 2) else 0) for x in range(cell)] for y in range(cell)]
        put(index * cell, cell * 2, tag)
    return rows


def main():
    work = sys.argv[1]
    os.makedirs(work, exist_ok=True)
    os.makedirs(os.path.join(ROOT, "swf", "badges"), exist_ok=True)
    os.makedirs(os.path.join(ROOT, "public", "badges"), exist_ok=True)
    star_xml = os.path.join(work, "star.xml")
    subprocess.run(["java", "-jar", FFDEC, "-swf2xml", os.path.join(ROOT, "cache", DEPLOY_VERSION, "media", hashed(STAR)), star_xml],
                   check=True, stdout=subprocess.DEVNULL)
    xml = open(star_xml, encoding="utf-8").read()
    # the second shape is the star; the first is the square behind it.
    shape = re.search(r'<item type="DefineShapeTag"[^>]*shapeId="3">.*?</item>\s*<item type="DefineSpriteTag"', xml, re.S).group(0)
    clockwise = area(star_points(shape)) > 0
    cards, outlines = [], []
    for name, outline, top, bottom, rim in BADGES:
        paths = outline()
        bounds, edges = records(paths, clockwise)
        changed = re.sub(r'<shapeBounds [^>]*/>', bounds, shape, count=1)
        changed = re.sub(r'<shapeRecords>.*?</shapeRecords>', "<shapeRecords>\n" + edges + "\n</shapeRecords>", changed, count=1, flags=re.S)
        made = xml.replace(shape, changed).replace("iconStar", "icon" + name.capitalize())
        made_xml = os.path.join(work, name + ".xml")
        open(made_xml, "w", encoding="utf-8").write(made)
        out = os.path.join(ROOT, "swf", "badges", name + ".swf")
        subprocess.run(["java", "-jar", FFDEC, "-xml2swf", made_xml, out], check=True, stdout=subprocess.DEVNULL)
        card = card_pixels(paths, top, bottom, rim)
        open(os.path.join(ROOT, "public", "badges", name + ".png"), "wb").write(png(card))
        cards.append(card)
        outlines.append(paths)
        print(name, os.path.getsize(out), "bytes")
    open(os.path.join(work, "sheet.png"), "wb").write(png(sheet(cards, outlines)))


if __name__ == "__main__":
    main()
