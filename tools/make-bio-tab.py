#!/usr/bin/env python3
"""Makes swf/biotab.swf, the artwork of the Bio tab on player cards.

  python3 tools/make-bio-tab.py <workdir>

The card (media 4620, from cache/) has two tabs that slide out of its left
side: the buddy games' at the top and the trade list's at the bottom. Each
is a brown frame with an ear on its left edge, and a blue button on the
ear. The Bio tab goes between them, so it needs a frame with its ear in
the middle, and a button with no picture on it (the card code puts
public/bio-icon.png there). This makes both from the card's own artwork
and leaves everything else in the file as it is, so that the card code can
load the result as it loads the card and take the tab out of it, button
class and all:

  - the games tab's frame is drawn again with the ear EAR_DOWN pixels
    lower, and its top left corner rounded as its bottom left one is;
  - the trade list's button loses its arrows: each of its four pictures is
    a stack of layers, the arrows being the last six;
  - the games tab gets that button in place of its own, on the ear.

Needs Java, for tools/ffdec.
"""
import hashlib
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
FFDEC = os.path.join(HERE, "ffdec", "ffdec-cli.jar")
DEPLOY_VERSION = "1830"
CARD = "4620"

FRAME_SHAPE = 366  # the games tab's frame
GAMES_TAB = 372
GAMES_BUTTON = 294
TRADE_BUTTON = 312
# the trade button's pictures, and how many layers of each are the button itself.
BUTTON_LAYERS = {307: 4, 309: 4, 305: 3, 303: 3}  # up, mouse over, down, grey
EAR_DOWN = 66  # the games tab's ear is at the top; this far down is midway to the trade list's


def hashed(name):
    """LoaderCache.hashItV2, as in lib/cdn.js."""
    salted = "W3 7r4Ck h4X0r3rs" + name
    out = ""
    for index, char in enumerate(salted):
        out = out + char if index % 2 == 0 else char + out
    return hashlib.md5(out.encode()).hexdigest()


def frame_path(inset, d):
    """The frame's outline, `inset` pixels in from its edge, as ("M" | "L",
    x, y) and ("Q", control x, control y, x, y). The numbers are the
    original's, the ear's with `d` added."""
    if inset:
        left, ear_left, top, bottom, right = -78, -130.9, -97.5, 97.5, 131
        ear_top, ear_bottom = -84.8 + d, -27.9 + d
        ear = [("Q", -119.8, ear_top, -125.4, -79.2 + d), ("Q", ear_left, -73.7 + d, ear_left, -65.8 + d), ("L", ear_left, -46.9 + d),
               ("Q", ear_left, -39.0 + d, -125.4, -33.4 + d), ("Q", -119.8, ear_bottom, -112, ear_bottom)]
        corner = [("Q", left, 88.8, -73.5, 93.1), ("Q", -69.2, bottom, -63, bottom)]
    else:
        left, ear_left, top, bottom, right = -80, -132.9, -99.5, 99.5, 133
        ear_top, ear_bottom = -86.8 + d, -25.9 + d
        ear = [("Q", -120.7, ear_top, -126.8, -80.7 + d), ("Q", ear_left, -74.5 + d, ear_left, -65.8 + d), ("L", ear_left, -46.9 + d),
               ("Q", ear_left, -38.1 + d, -126.8, -32.0 + d), ("Q", -120.7, ear_bottom, -112, ear_bottom)]
        corner = [("Q", left, 89.5, -75, 94.5), ("Q", -70, bottom, -63, bottom)]
    # the top left corner, which the original's ear ran into: the bottom one, upside down.
    (_, c1x, c1y, m1x, m1y), (_, c2x, c2y, _, _) = corner
    top_corner = [("Q", c2x, -c2y, m1x, -m1y), ("Q", c1x, -c1y, left, -82.5)]
    return [("M", left, ear_top), ("L", -112, ear_top)] + ear + [("L", left, ear_bottom), ("L", left, 82.5)] + corner \
        + [("L", right, bottom), ("L", right, top), ("L", -63, top)] + top_corner + [("L", left, ear_top)]


def backwards(path):
    points = [(step[-2], step[-1]) for step in path]
    out = [("M",) + points[-1]]
    for index in range(len(path) - 1, 0, -1):
        step = path[index]
        out.append(step[:-2] + points[index - 1])
    return out


def path_records(path, first):
    """SWF shape records for a path, in twips. `first` is put into the
    record that moves to its start."""
    out, x, y = [], 0, 0
    twips = lambda value: round(value * 20)
    for step in path:
        if step[0] == "M":
            x, y = twips(step[1]), twips(step[2])
            out.append('<item type="StyleChangeRecord" %s moveBits="15" moveDeltaX="%d" moveDeltaY="%d" stateLineStyle="false" '
                       'stateMoveTo="true" stateNewStyles="false"/>' % (first, x, y))
        elif step[0] == "L":
            nx, ny = twips(step[1]), twips(step[2])
            if (nx, ny) != (x, y):
                out.append('<item type="StraightEdgeRecord" deltaX="%d" deltaY="%d" generalLineFlag="true" numBits="13" vertLineFlag="false"/>'
                           % (nx - x, ny - y))
            x, y = nx, ny
        else:
            cx, cy, nx, ny = (twips(value) for value in step[1:])
            out.append('<item type="CurvedEdgeRecord" anchorDeltaX="%d" anchorDeltaY="%d" controlDeltaX="%d" controlDeltaY="%d" numBits="13"/>'
                       % (nx - cx, ny - cy, cx - x, cy - y))
            x, y = nx, ny
    return out


def shape_tag(xml, shape_id):
    return re.search(r'<item type="DefineShape\d?Tag"[^>]*shapeId="%d">.*?</shapes>\s*</item>' % shape_id, xml, re.S).group(0)


def new_frame(xml):
    """The frame as two layers, as the original has it: the brown inside,
    then the dark rim around it (the outline, with the inside as a hole)."""
    tag = shape_tag(xml, FRAME_SHAPE)
    # the record between the layers, which carries the second layer's colour.
    new_styles = re.search(r'<item type="StyleChangeRecord"[^>]*stateNewStyles="true">.*?</lineStyles>\s*</item>', tag, re.S).group(0)
    fill, keep = 'fillStyle0="1" stateFillStyle0="true" stateFillStyle1="false"', 'stateFillStyle0="false" stateFillStyle1="false"'
    inner, outer = frame_path(2, EAR_DOWN), frame_path(0, EAR_DOWN)
    records = path_records(inner, fill) + [new_styles] + path_records(outer, fill) + path_records(backwards(inner), keep) \
        + ['<item type="EndShapeRecord" endOfShape="0"/>']
    return xml.replace(tag, re.sub(r'<shapeRecords>.*</shapeRecords>', "<shapeRecords>\n" + "\n".join(records) + "\n</shapeRecords>",
                                   tag, count=1, flags=re.S))


def without_picture(xml, shape_id, layers):
    """A button picture with only its first `layers` layers."""
    tag = shape_tag(xml, shape_id)
    starts = [match.start() for match in re.finditer(r'<item type="StyleChangeRecord"[^>]*stateNewStyles="true"', tag)]
    cut = starts[layers - 1]  # the record that begins the layer after the last one kept
    end = tag.rindex('<item type="EndShapeRecord"')
    return xml.replace(tag, tag[:cut] + tag[end:])


def main():
    work = sys.argv[1]
    os.makedirs(work, exist_ok=True)
    card_xml = os.path.join(work, "card.xml")
    subprocess.run(["java", "-jar", FFDEC, "-swf2xml", os.path.join(ROOT, "cache", DEPLOY_VERSION, "media", hashed(CARD)), card_xml],
                   check=True, stdout=subprocess.DEVNULL)
    xml = open(card_xml, encoding="utf-8").read()
    xml = new_frame(xml)
    for shape_id, layers in BUTTON_LAYERS.items():
        xml = without_picture(xml, shape_id, layers)
    # the games tab's button: the trade list's, on the ear where it is now.
    tab = re.search(r'<item type="DefineSpriteTag"[^>]*spriteId="%d">.*?</subTags>' % GAMES_TAB, xml, re.S).group(0)
    place = re.search(r'<item type="PlaceObject2Tag" characterId="%d"[^>]*name="gameTabBtn"[^>]*>\s*<matrix [^>]*/>' % GAMES_BUTTON, tab).group(0)
    moved = place.replace('characterId="%d"' % GAMES_BUTTON, 'characterId="%d"' % TRADE_BUTTON)
    y = int(re.search(r'translateY="(-?\d+)"', place).group(1))
    moved = moved.replace('translateY="%d"' % y, 'translateY="%d"' % (y + EAR_DOWN * 20))
    xml = xml.replace(tab, tab.replace(place, moved))
    made_xml = os.path.join(work, "biotab.xml")
    open(made_xml, "w", encoding="utf-8").write(xml)
    out = os.path.join(ROOT, "swf", "biotab.swf")
    subprocess.run(["java", "-jar", FFDEC, "-xml2swf", made_xml, out], check=True, stdout=subprocess.DEVNULL)
    print(out, os.path.getsize(out), "bytes")


if __name__ == "__main__":
    main()
