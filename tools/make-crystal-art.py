#!/usr/bin/env python3
# the Earth Crystals' art, in one amber:
#
# - swf/HUDAssets.swf: the HUD's Earth Crystal (the shape inside the money
#   display's "crystals" clip) recoloured in place. running this again
#   changes nothing more.
# - swf/crystal-wheel.swf: the daily spin's wheel, the game's members' wheel
#   (media 5533) with the diamonds drawn on the wheel recoloured, and the
#   prize display's one to six diamonds swapped for that HUD crystal. its
#   two gift wedges show two crystals, as its double wedges do (each a
#   double wedge's drawing turned onto it, through a mask). the rest is the
#   game's. lib/crystals.js serves it as media SPIN_WHEEL_MEDIA, which the
#   patched GemBonusSpinWheel loads.
#
#   tools/make-crystal-art.py path/to/media-5533.swf
#
# needs Java (tools/ffdec).
import colorsys
import math
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
FFDEC = os.path.join(HERE, "ffdec", "ffdec-cli.jar")
SWF = os.path.join(HERE, "..", "swf")
HUD = os.path.join(SWF, "HUDAssets.swf")
WHEEL = os.path.join(SWF, "crystal-wheel.swf")

# the wheel: the shape of the wheel itself, whose diamonds are drawn into
# it, and the clip of the prize display, whose frames 1 to 6 hold one shape
# of that many diamonds each
WHEEL_SHAPE = "65"
PRIZE_SPRITE = "34"
PRIZE_SHAPES = ["28", "29", "30", "31", "32", "33"]
# the clip that turns, with the wheel's shape at WHEEL_DEPTH and its sparkles
# above. the wheel is sixteen slots of 22.5 degrees around its centre (0, 0),
# radius WHEEL_RADIUS twips; the gift wedges (screen degrees, clockwise from
# east) are each a double wedge's place turned back a quarter, so one copy of
# the wheel turned -90 degrees shows doubles in both, seen through a mask of
# the two. the copy goes between the wheel and its sparkles.
WHEEL_SPRITE = "69"
WHEEL_DEPTH = 116
GIFT_WEDGES = [(247.5, 270.0), (67.5, 90.0)]
WHEEL_RADIUS = 2560
# the diamonds' blues (their dark outline, 3a1d11, stays)
DIAMOND_BLUES = {"3592cd", "3785cd", "3785cc", "3b9ec8", "4fa19d", "5db8cd", "64b3ad", "70cef4", "84d8e2", "c1ecf3", "e9faf0"}

COLOR = re.compile(r'<color type="RGBA?"[^>]*/>')


# the one amber: a colour's lightness kept, its hue from about 18 degrees in
# the darks to 45 in the lights, as the HUD's crystal was drawn
def amber(hex_colour):
    r, g, b = (int(hex_colour[i:i + 2], 16) / 255 for i in (0, 2, 4))
    _, lightness, saturation = colorsys.rgb_to_hls(r, g, b)
    hue = 18 + max(0.0, min(1.0, (lightness - 0.25) / 0.65)) * 27
    r, g, b = colorsys.hls_to_rgb(hue / 360, lightness, max(saturation, 0.7))
    return round(r * 255), round(g * 255), round(b * 255)


def recolour(segment, wanted):
    def one(match):
        attrs = match.group(0)
        colour = "%02x%02x%02x" % tuple(int(re.search(name + r'="(\d+)"', attrs).group(1)) for name in ("red", "green", "blue"))
        if not wanted(colour):
            return attrs
        r, g, b = amber(colour)
        for name, value in (("red", r), ("green", g), ("blue", b)):
            attrs = re.sub(name + r'="\d+"', '%s="%d"' % (name, value), attrs)
        return attrs
    return COLOR.sub(one, segment)


def ffdec(*args):
    subprocess.run(["java", "-jar", FFDEC, *args], check=True, stdout=subprocess.DEVNULL)


# a definition tag's span in the XML, by its id: (start, end)
def definition(xml, kind, ident):
    match = re.search(r'<item type="%s"[^>]*?(?:shapeId|spriteId)="%s"' % (kind, ident), xml)
    if not match:
        sys.exit("%s %s not found" % (kind, ident))
    end = xml.find('<item type="Define', match.end())
    return match.start(), len(xml) if end == -1 else end


def replace_span(xml, span, text):
    return xml[:span[0]] + text + xml[span[1]:]


# the HUD's crystal shape: the money display places a clip named "crystals",
# whose drawing is a clip holding one shape
def hud_crystal(xml):
    placed = re.search(r'<item type="PlaceObject[23]Tag" characterId="(\d+)"[^>]*name="crystals"', xml)
    for child in re.findall(r'PlaceObject[23]Tag" characterId="(\d+)"', xml[slice(*definition(xml, "DefineSpriteTag", placed.group(1)))]):
        sprite = xml[slice(*definition(xml, "DefineSpriteTag", child))]
        shapes = re.findall(r'PlaceObject[23]Tag" characterId="(\d+)"', sprite)
        if len(shapes) == 1 and re.search(r'<item type="DefineShape\d?Tag"[^>]*shapeId="%s"' % shapes[0], xml):
            return shapes[0]
    sys.exit("the HUD's crystal shape not found")


def bits(*values):
    return max((int(v).bit_length() if v >= 0 else (~int(v)).bit_length()) + 1 for v in values)


def place(char, depth, scale, x, y):
    tx, ty = round(x), round(y)
    return ('<item type="PlaceObject2Tag" characterId="%s" depth="%d" forceWriteAsLong="false" placeFlagHasCharacter="true" '
            'placeFlagHasClipActions="false" placeFlagHasClipDepth="false" placeFlagHasColorTransform="false" placeFlagHasMatrix="true" '
            'placeFlagHasName="false" placeFlagHasRatio="false" placeFlagMove="false">'
            '<matrix type="MATRIX" hasRotate="false" hasScale="true" nRotateBits="0" nScaleBits="%d" nTranslateBits="%d" '
            'scaleX="%.6f" scaleY="%.6f" translateX="%d" translateY="%d"/></item>'
            % (char, depth, bits(round(scale * 65536)), bits(tx, ty), scale, scale, tx, ty))


def bounds(shape_xml):
    b = re.search(r'<shapeBounds[^>]*/>', shape_xml).group(0)
    return [int(re.search(name + r'="(-?\d+)"', b).group(1)) for name in ("Xmin", "Xmax", "Ymin", "Ymax")]


# where n crystals stand in the prize display, in the place n diamonds took:
# one row for one or two, then a back row and a front row, overlapping as
# the diamonds were piled, and smaller the more there are. centres as fractions of a crystal's size.
def layout(count):
    back = count // 2 if count > 2 else 0
    front = count - back
    rows = [(back, -0.22), (front, 0.22)] if back else [(front, 0.0)]
    spots = []
    for n, y in rows:
        for i in range(n):
            spots.append(((i - (n - 1) / 2) * 0.6, y))
    return spots


def prize_frames(xml, crystal_id, crystal_bounds):
    cx0, cx1, cy0, cy1 = crystal_bounds
    tags = ['<item type="SoundStreamHead2Tag" forceWriteAsLong="false" playBackSoundRate="3" playBackSoundSize="true" '
            'playBackSoundType="false" reserved="0" streamSoundCompression="0" streamSoundRate="0" streamSoundSampleCount="0" '
            'streamSoundSize="false" streamSoundType="false"/>']
    used = []
    for count, shape in enumerate(PRIZE_SHAPES, 1):
        x0, x1, y0, y1 = bounds(xml[slice(*definition(xml, r"DefineShape\d?Tag", shape))])
        # one crystal as tall as one diamond, a little smaller with more
        scale = (bounds(xml[slice(*definition(xml, r"DefineShape\d?Tag", PRIZE_SHAPES[0]))])[3]
                 - bounds(xml[slice(*definition(xml, r"DefineShape\d?Tag", PRIZE_SHAPES[0]))])[2]) / (cy1 - cy0)
        scale *= 1.0 if count <= 2 else 0.85 if count <= 4 else 0.75
        width, height = (cx1 - cx0) * scale, (cy1 - cy0) * scale
        centre = ((x0 + x1) / 2, (y0 + y1) / 2)
        for depth in used:
            tags.append('<item type="RemoveObject2Tag" depth="%d" forceWriteAsLong="false"/>' % depth)
        used = []
        for i, (fx, fy) in enumerate(layout(count), 1):
            x = centre[0] + fx * width - width / 2 - cx0 * scale
            y = centre[1] + fy * height - height / 2 - cy0 * scale
            tags.append(place(crystal_id, i, scale, x, y))
            used.append(i)
        tags.append('<item type="ShowFrameTag" forceWriteAsLong="false"/>')
    return ('<item type="DefineSpriteTag" forceWriteAsLong="true" frameCount="6" hasEndTag="true" spriteId="%s"><subTags>%s</subTags></item>\n'
            % (PRIZE_SPRITE, "".join(tags)))


# a shape of the gift wedges, a little wider and to just inside the rim, for
# a mask: the copy's wedge borders and rim fall where the wheel's own do
def gift_mask(shape_id):
    radius = WHEEL_RADIUS - 30
    records = []
    points = []
    for first, last in GIFT_WEDGES:
        steps = 16
        arc = [(round(radius * math.cos(math.radians(first - 1 + (last - first + 2) * i / steps))),
                round(radius * math.sin(math.radians(first - 1 + (last - first + 2) * i / steps)))) for i in range(steps + 1)]
        points += arc
        style = (' fillStyle0="1" stateFillStyle0="true"' if not records else ' stateFillStyle0="false"')
        records.append('<item type="StyleChangeRecord"%s moveBits="1" moveDeltaX="0" moveDeltaY="0" stateFillStyle1="false" '
                       'stateLineStyle="false" stateMoveTo="true" stateNewStyles="false"/>' % style)
        at = (0, 0)
        for point in arc + [(0, 0)]:
            dx, dy = point[0] - at[0], point[1] - at[1]
            records.append('<item type="StraightEdgeRecord" deltaX="%d" deltaY="%d" generalLineFlag="true" numBits="%d"/>'
                           % (dx, dy, max(bits(dx, dy) - 2, 0)))
            at = point
    records.append('<item type="EndShapeRecord" endOfShape="0"/>')
    xs = [x for x, _ in points] + [0]
    ys = [y for _, y in points] + [0]
    return ('<item type="DefineShapeTag" forceWriteAsLong="true" shapeId="%s">'
            '<shapeBounds type="RECT" Xmax="%d" Xmin="%d" Ymax="%d" Ymin="%d" nbits="%d"/>'
            '<shapes type="SHAPEWITHSTYLE" numFillBits="1" numLineBits="0"><fillStyles type="FILLSTYLEARRAY"><fillStyles>'
            '<item type="FILLSTYLE" fillStyleType="0"><color type="RGB" blue="0" green="0" red="0"/></item></fillStyles></fillStyles>'
            '<lineStyles type="LINESTYLEARRAY"><lineStyles/></lineStyles><shapeRecords>%s</shapeRecords></shapes></item>\n'
            % (shape_id, max(xs), min(xs), max(ys), min(ys), bits(max(xs), min(xs), max(ys), min(ys)), "".join(records)))


# the wheel's clip with the turned copy under the mask, the wheel itself
# moved down three depths to make room (nothing else in the clip is below it)
def swap_gifts(xml, mask_id):
    start = definition(xml, "DefineSpriteTag", WHEEL_SPRITE)[0]
    end = xml.index("</subTags>", start)
    clip = xml[start:end]
    own = re.search(r'<item type="PlaceObject2Tag" characterId="%s" depth="%d"' % (WHEEL_SHAPE, WHEEL_DEPTH), clip)
    if not own:
        sys.exit("the wheel's shape not found in its clip")
    close = clip.index("</item>", own.end()) + len("</item>")
    moved = clip[own.start():close].replace('depth="%d"' % WHEEL_DEPTH, 'depth="%d"' % (WHEEL_DEPTH - 3), 1)
    mask = ('<item type="PlaceObject2Tag" characterId="%s" clipDepth="%d" depth="%d" forceWriteAsLong="false" placeFlagHasCharacter="true" '
            'placeFlagHasClipActions="false" placeFlagHasClipDepth="true" placeFlagHasColorTransform="false" placeFlagHasMatrix="true" '
            'placeFlagHasName="false" placeFlagHasRatio="false" placeFlagMove="false">'
            '<matrix type="MATRIX" hasRotate="false" hasScale="false" nRotateBits="0" nScaleBits="0" nTranslateBits="0" translateX="0" translateY="0"/></item>'
            % (mask_id, WHEEL_DEPTH - 1, WHEEL_DEPTH - 2))
    # turned -90 degrees: (x, y) to (y, -x)
    turned = ('<item type="PlaceObject2Tag" characterId="%s" depth="%d" forceWriteAsLong="false" placeFlagHasCharacter="true" '
              'placeFlagHasClipActions="false" placeFlagHasClipDepth="false" placeFlagHasColorTransform="false" placeFlagHasMatrix="true" '
              'placeFlagHasName="false" placeFlagHasRatio="false" placeFlagMove="false">'
              '<matrix type="MATRIX" hasRotate="true" hasScale="true" nRotateBits="%d" nScaleBits="1" nTranslateBits="0" '
              'rotateSkew0="-1.0" rotateSkew1="1.0" scaleX="0.0" scaleY="0.0" translateX="0" translateY="0"/></item>'
              % (WHEEL_SHAPE, WHEEL_DEPTH - 1, bits(65536, -65536)))
    clip = clip[:own.start()] + moved + mask + turned + clip[close:]
    return xml[:start] + clip + xml[end:]


def main(source):
    with tempfile.TemporaryDirectory() as work:
        # the HUD's crystal, in the amber
        hud_xml_path = os.path.join(work, "hud.xml")
        ffdec("-swf2xml", HUD, hud_xml_path)
        hud = open(hud_xml_path, encoding="utf-8").read()
        crystal = hud_crystal(hud)
        span = definition(hud, r"DefineShape\d?Tag", crystal)
        crystal_xml = recolour(hud[slice(*span)], lambda colour: colour != "ffffff")
        hud = replace_span(hud, span, crystal_xml)
        open(hud_xml_path, "w", encoding="utf-8").write(hud)
        ffdec("-xml2swf", hud_xml_path, HUD)

        # the wheel: its own diamonds recoloured, the prize display's swapped
        wheel_xml_path = os.path.join(work, "wheel.xml")
        ffdec("-swf2xml", source, wheel_xml_path)
        wheel = open(wheel_xml_path, encoding="utf-8").read()
        span = definition(wheel, r"DefineShape\d?Tag", WHEEL_SHAPE)
        wheel = replace_span(wheel, span, recolour(wheel[slice(*span)], lambda colour: colour in DIAMOND_BLUES))
        new_id = str(max(int(i) for i in re.findall(r'(?:shapeId|spriteId|fontId|buttonId|characterId|characterID)="(\d+)"', wheel)) + 1)
        mask_id = str(int(new_id) + 1)
        copied = re.sub(r'shapeId="%s"' % crystal, 'shapeId="%s"' % new_id, crystal_xml, count=1)
        # the clip exactly, to its own end: clips hold no clips' definitions
        start = definition(wheel, "DefineSpriteTag", PRIZE_SPRITE)[0]
        end = wheel.index("</item>", wheel.index("</subTags>", start)) + len("</item>")
        wheel = replace_span(wheel, (start, end), copied + prize_frames(wheel, new_id, bounds(crystal_xml)))
        # the gift wedges: the mask defined before the clip that uses it
        start = definition(wheel, "DefineSpriteTag", WHEEL_SPRITE)[0]
        wheel = swap_gifts(wheel[:start] + gift_mask(mask_id) + wheel[start:], mask_id)
        open(wheel_xml_path, "w", encoding="utf-8").write(wheel)
        ffdec("-xml2swf", wheel_xml_path, WHEEL)
    print("made", os.path.normpath(HUD), "and", os.path.normpath(WHEEL))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: tools/make-crystal-art.py path/to/media-5533.swf")
    main(sys.argv[1])
