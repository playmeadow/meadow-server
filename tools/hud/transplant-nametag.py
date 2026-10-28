"""transplant-nametag.py old.xml now.xml out.xml

Puts the name tags of the March 2014 HUDAssets.swf into today's. Both files
are given as the XML `ffdec-cli -swf2xml` writes; the result goes back
through `-xml2swf`. Everything is found by symbol and instance name, so it
does not depend on either file's character ids.

What changes, and only this:

  member tag    The 2014 left cap and bar ("e" and "n" of memberNameBar, a
                clip each with one hand-drawn frame per colour) are copied
                in under new ids and added as a child named "old" on top of
                what today's "e" and "m" already hold. Nothing of today's is
                taken out: avatar.NameBar reaches into those two for a child
                called "mouse", and no login survives its absence. The old
                clips carry the same offsets inside as today's parts, so
                they go in at 0,0. swf-src/hud/memberNameBar.as shows the
                right frame and hides today's drawing.
  picker        The ten samples in the animal editor (namebar_<colour>Cont):
                the "up" and "mouse" drawings inside each one's "mouse" clip
                are swapped for the 2014 ones, which sit at the same places.
  free tag      Its drawing has not changed since 2014, pixel for pixel; the
                name on it was in the regular weight then and is bold now.
                The text field goes back to the regular font.
"""
import re
import sys
import xml.etree.ElementTree as ET

old_path, now_path, out_path = sys.argv[1:4]
COLOURS = ["black", "blue", "brown", "gold", "green", "pink", "purple", "red", "teal", "white"]
OLD_DEPTH = 40  # above the parts already in today's cap and bar
ID_ATTRS = ("spriteId", "shapeId", "characterId", "characterID", "bitmapId", "fontId", "buttonId")


def read(path):
    """-> (definitions by character id, character id by symbol name)"""
    tags = ET.parse(path).getroot().find("tags")
    defs, names = {}, {}
    for item in tags:
        kind = item.get("type", "")
        if kind == "SymbolClassTag":
            ids = [entry.text for entry in item.find("tags")]
            for cid, name in zip(ids, (entry.text for entry in item.find("names"))):
                names[name] = cid
        elif kind.startswith("Define"):
            for attr in ("spriteId", "shapeId", "characterID", "buttonId", "fontId"):
                if item.get(attr):
                    defs.setdefault(item.get(attr), item)
    return defs, names


def child(defs, sprite_id, name):
    """Character id of the child called `name` on a sprite's first frame."""
    for tag in defs[sprite_id].find("subTags"):
        if tag.get("type") == "ShowFrameTag":
            break
        if tag.get("name") == name and tag.get("characterId"):
            return tag.get("characterId")
    raise SystemExit(f"sprite {sprite_id} has no child called {name}")


old, old_names = read(old_path)
now, now_names = read(now_path)

wanted = {}
old_tag, now_tag = old_names["memberNameBar"], now_names["memberNameBar"]
add_old = {  # today's sprite -> the 2014 clip it gets as "old"
    child(now, now_tag, "e"): child(old, old_tag, "e"),
    child(now, now_tag, "m"): child(old, old_tag, "n"),
}
retarget = {}  # (today's sprite, child name) -> the 2014 character to place there
for colour in COLOURS:
    symbol = f"namebar_{colour}Cont"
    old_states = child(old, old_names[symbol], "mouse")
    now_states = child(now, now_names[symbol], "mouse")
    for state in ("up", "mouse"):
        retarget[(now_states, state)] = child(old, old_states, state)
for cid in list(add_old.values()) + list(retarget.values()):
    wanted[cid] = True


def references(element):
    found = set()
    for sub in element.iter():
        if sub is element:
            continue
        for attr in ("characterId", "bitmapId", "fontId"):
            value = sub.get(attr)
            if value and value != "65535":
                found.add(value)
    return found


order, seen = [], set()


def visit(cid):
    if cid in seen:
        return
    if cid not in old:
        raise SystemExit(f"the 2014 file has no definition for character {cid}")
    seen.add(cid)
    for ref in sorted(references(old[cid]), key=int):
        visit(ref)
    order.append(cid)  # what a thing is made of comes before it


for cid in wanted:
    visit(cid)
kinds = {}
for cid in order:
    kinds[old[cid].get("type")] = kinds.get(old[cid].get("type"), 0) + 1
print("copying", len(order), "definitions:", kinds)

text = open(now_path, encoding="utf8").read()
highest = max(int(value) for value in re.findall(r'(?:spriteId|shapeId|characterID|buttonId|fontId|characterId)="(\d+)"', text) if int(value) < 60000)
new_id = {cid: str(highest + 1 + index) for index, cid in enumerate(order)}
chunks = []
for cid in order:
    element = old[cid]
    for sub in element.iter():
        for attr in ID_ATTRS:
            if sub.get(attr) in new_id:
                sub.set(attr, new_id[sub.get(attr)])
    chunks.append(ET.tostring(element, encoding="unicode").strip())


def sprite_span(source, sprite_id):
    """(start, end) of a sprite's definition in the XML text."""
    start = re.search(r'[ \t]*<item type="DefineSpriteTag"[^>]*spriteId="%s"[^>]*>' % sprite_id, source)
    assert start, f"sprite {sprite_id} not found in today's file"
    indent = re.match(r'[ \t]*', start.group(0)).group(0)
    closing = "\n" + indent + "</item>"
    return start.start(), source.index(closing, start.end()) + len(closing)


free_text = child(now, child(now, now_names["FreeNameBar"], "c"), "txt")
field = re.search(r'<item type="DefineEditTextTag"[^>]*characterID="%s"[^>]*>' % free_text, text)
assert field and 'fontClass="CCDigitalDeliveryBold"' in field.group(0)
plain = field.group(0).replace('fontClass="CCDigitalDeliveryBold"', 'fontClass="CCDigitalDeliveryRegular"').replace("&lt;b&gt;", "").replace("&lt;/b&gt;", "")
text = text[:field.start()] + plain + text[field.end():]

for (sprite_id, name), old_cid in retarget.items():
    start, end = sprite_span(text, sprite_id)
    sprite = text[start:end]
    pattern = re.compile(r'(<item type="PlaceObject[23]Tag"[^>]*?)characterId="\d+"([^>]*?name="%s")' % name)
    sprite, count = pattern.subn(lambda match: f'{match.group(1)}characterId="{new_id[old_cid]}"{match.group(2)}', sprite)
    assert count == 1, (sprite_id, name, count)
    text = text[:start] + sprite + text[end:]

for sprite_id, old_cid in add_old.items():
    start, end = sprite_span(text, sprite_id)
    show = text.index('<item type="ShowFrameTag"', start)
    assert show < end
    place = ('<item type="PlaceObject2Tag" characterId="%s" depth="%d" forceWriteAsLong="true" name="old" '
             'placeFlagHasCharacter="true" placeFlagHasClipActions="false" placeFlagHasClipDepth="false" '
             'placeFlagHasColorTransform="false" placeFlagHasMatrix="true" placeFlagHasName="true" '
             'placeFlagHasRatio="false" placeFlagMove="false">'
             '<matrix type="MATRIX" hasRotate="false" hasScale="false" nRotateBits="0" nScaleBits="0" '
             'nTranslateBits="0" translateX="0" translateY="0"/></item>\n        ') % (new_id[old_cid], OLD_DEPTH)
    text = text[:show] + place + text[show:]

first = min(sprite_span(text, sprite_id)[0] for sprite_id in list(add_old) + [key[0] for key in retarget])
indent = re.match(r'[ \t]*', text[first:]).group(0)
text = text[:first] + "".join(indent + chunk + "\n" for chunk in chunks) + text[first:]
open(out_path, "w", encoding="utf8").write(text)
print("written", out_path)
