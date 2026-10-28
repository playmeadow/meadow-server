#!/usr/bin/env python3
"""Builds lib/shop-stock.json: what each shop sells, from the AJ Classic Wiki.

    python3 tools/shop-stock.py <workdir> [<output file>]

The game's files say which shop list stands in which room and nothing about
what is on its shelves: the official server sent that. The wiki
(animaljam.fandom.com) has it. Every item page there carries the game's own
def id (the sort key of "Clothing by ID" / "Den Items by ID"), the category
of each shop selling it now ("Jam Mart Clothing") and of each that used to
("Formerly Jam Mart Clothing"). Shops that are gone, the party shops mostly,
list their items on the shop's own page instead.

LISTS below says which wiki shop is which generic list. Where that is a guess
it says so. <workdir> keeps what was downloaded (wiki.json, pages.json);
delete them to fetch the wiki again.

Written out per list: "now" (on the shelf according to the wiki) and
"former" (sold there once). lib/shopstock.js stocks all of "now" and those
of "former" that have sale dates, which bring them back in their season.
"""
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request

API = "https://animaljam.fandom.com/api.php"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib", "shop-stock.json")


def api(**params):
    params["format"] = "json"
    url = API + "?" + urllib.parse.urlencode(params)
    for attempt in range(4):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (shop research)"})
            return json.load(urllib.request.urlopen(request, timeout=60))
        except Exception:
            time.sleep(2 + attempt * 3)
    raise SystemExit("failed: " + url)


def members(category, sortkey=False):
    found, more = [], {}
    while True:
        reply = api(action="query", list="categorymembers", cmtitle="Category:" + category, cmlimit="500",
                    cmprop="title|sortkeyprefix" if sortkey else "title", **more)
        found += reply["query"]["categorymembers"]
        if "continue" not in reply:
            return found
        more = {"cmcontinue": reply["continue"]["cmcontinue"]}
        time.sleep(0.2)


def download(workdir):
    wiki_path, pages_path = os.path.join(workdir, "wiki.json"), os.path.join(workdir, "pages.json")
    if not os.path.exists(wiki_path):
        wiki = {"ids": {}, "shops": {}}
        for kind, category in (("clothing", "Clothing by ID"), ("den", "Den Items by ID")):
            wiki["ids"][kind] = {row["title"]: row["sortkeyprefix"] for row in members(category, True)}
        for shop in [row["title"] for row in members("Shops")]:
            if not shop.startswith("Category:"):
                wiki["shops"][shop] = {"now": [row["title"] for row in members(shop)],
                                       "former": [row["title"] for row in members("Formerly " + shop)]}
                time.sleep(0.2)
        json.dump(wiki, open(wiki_path, "w"))
    wiki = json.load(open(wiki_path))
    if not os.path.exists(pages_path):
        pages = {}
        for shop in wiki["shops"]:
            reply = api(action="parse", page=shop, prop="wikitext", redirects="1")
            pages[shop] = reply.get("parse", {}).get("wikitext", {}).get("*", "")
            time.sleep(0.15)
        json.dump(pages, open(pages_path, "w"))
    return wiki, json.load(open(pages_path))


# sections of a shop page that talk about items without listing the shelf.
NOT_THE_SHELF = re.compile(r"trivia|gallery|history|appearance|glitch|previously|formerly|see also", re.I)


def sections(text):
    """[(heading path, body)] of a page, the lead included under ""."""
    parts = re.split(r"^(=+)\s*(.*?)\s*=+\s*$", text, flags=re.M)
    found, path = [("", parts[0])], []
    for at in range(1, len(parts), 3):
        level, name = len(parts[at]), parts[at + 1]
        path = [step for step in path if step[0] < level] + [(level, name)]
        found.append((" / ".join(step[1] for step in path), parts[at + 2]))
    return [(head, body) for head, body in found if not NOT_THE_SHELF.search(head)]


def latest_tab(body):
    """Of a tabbed list by year, the first tab: the latest years."""
    body = re.sub(r"\{\{Tabber\s*\|[^|]*\|(\{\{[^{}]*\}\}).*?(?=\n==|\Z)", r"\1", body, flags=re.S)
    return re.sub(r"<tabber>\s*\|-\|[^=\n]*=(.*?)(?:\|-\|.*?)?</tabber>", r"\1", body, flags=re.S)


def names(body):
    """Item names in a stretch of wikitext: item tables and links."""
    found = []
    for table in re.finditer(r"\{\{(?:ItemTable|CollectionTable)\s*\|([^{}]*)\}\}", body):
        for cell in re.split(r"[|,;]", table.group(1)):
            found.append(cell.split("::")[0].strip())
    found += [link.group(1).strip() for link in re.finditer(r"\[\[([^\]|#]+)", body)]
    return found


# what a list takes from the wiki: (shop, where, heading, name).
#   where    "category": the shop's item category, now and formerly;
#            "page": the items listed on the shop's page.
#   heading  with "page", only sections whose heading path matches.
#   name     only items whose name matches (a leading "!" for "does not").
def category(shop, name=None):
    return (shop, "category", None, name)


def page(shop, heading=None, name=None):
    return (shop, "page", heading, name)


NEW_YEARS = ["Chinese New Year Shop"] + ["Year of the %s Shop" % animal for animal in (
    "Dog", "Dragon", "Horse", "Ox", "Pig", "Rabbit", "Rat", "Rooster", "Snake", "Tiger")]
PARTY_MUSIC = r"music"

# generic list id -> what it sells. "music": True keeps only music tracks,
# False keeps them out (a party's furniture stand next to its jukebox).
# "kinds" names the one kind a diamond list sells, which can hold both.
LISTS = {
    # the lands. 11, 50, 12, 51, 56, 85 and 234 are named in the client
    # (GenericListXtCommManager); the rest follow from the room each list
    # stands in.
    11: {"from": [category("Jam Mart Clothing")]},
    12: {"from": [category("Jam Mart Furniture")], "music": False},
    234: {"from": [category("Jam Mart Furniture (New Jammer)")]},
    56: {"from": [category("Music Shop")], "music": True},
    5: {"from": [category("Shiveer Shoppe")]},
    9: {"from": [category("Mystery Emporium")]},
    113: {"from": [category("Treetop Gardens")]},
    323: {"from": [category("Topiary Shop")]},
    589: {"from": [category("Topiary Shop (Lit)")]},
    778: {"from": [category("Eco Shop")]},
    362: {"from": [category("Theater Shop")]},
    184: {"from": [category("Museum Shop")]},
    85: {"from": [category("Pet Den Item Shop")]},
    50: {"from": [category("Bahari Bargains")]},
    51: {"from": [category("Sunken Treasures")]},
    626: {"from": [category("Ocean Diamond Shop")], "kinds": ["clothing"]},  # the clam in Bahari Bargains: clothing
    625: {"from": [category("Ocean Diamond Shop")], "kinds": ["den"]},  # the shelf in Sunken Treasures: den items
    250: {"from": [category("Marine Marvels")]},
    212: {"from": [page("Royal Ridge")]},  # "airshop": the one only flying animals reach
    59: {"from": [category("Epic Wonders")]},
    423: {"from": [category("Epic Wonders")], "kinds": ["den"]},  # the lower orb
    420: {"from": [category("Studio Corner")]},
    63: {"from": [category("Sol Arcade Shop")]},
    374: {"from": [category("Astronomy Shop")]},
    177: {"from": [category("Outback Imports")]},
    178: {"from": [category("Hospital Shop")]},
    179: {"from": [category("Adventure Shop")]},
    687: {"from": [category("Ancient Antiquities")]},
    # guessed which of the temple's two windows is which, by the order the
    # shops opened in (the armory first).
    688: {"from": [category("Ancient Armory")]},
    713: {"from": [category("Ancient Treasures")]},
    801: {"from": [category("Jambassador Plushie Shop")]},
    790: {"from": [category("Spooky Shop (Phantom Vortex)")]},
    584: {"from": [page(r"??? (Epic Dens)")]},
    # the two shops this server filled with what was never sold anywhere
    # (ODDITY_SHOPS in lib/world.js) get their real shelves in front of that.
    396: {"from": [page(r"??? (Basement of Secrets)")]},
    666: {"from": [category("Forgotten Relics")]},

    # the Diamond Shop. guessed: 415 as the clothing window (the newer list;
    # the two were one window until 2016), 167 as the den items, 168
    # ("armor") as the armour among the clothing.
    415: {"from": [category("Diamond Shop")], "kinds": ["clothing"]},
    168: {"from": [category("Diamond Shop", r"armou?r|helmet|gauntlet|amulet|sword|shield")], "kinds": ["clothing"]},
    167: {"from": [category("Diamond Shop", r"!mannequin")], "kinds": ["den"], "music": False},
    173: {"from": [category("Diamond Shop")], "kinds": ["den"], "music": True},
    684: {"from": [page("Diamond Shop", r"^Mannequins")]},
    689: {"from": [page("Diamond Shop", r"^Deep Blue")]},
    # alpha Headquarters: six stands, one alpha's armour each. guessed which
    # stand is whose (the stands are numbered 1 to 6 in the room file, the
    # alphas taken in the wiki's order).
    677: {"from": [category("Alpha Headquarters", r"peck")]},
    678: {"from": [category("Alpha Headquarters", r"greely")]},
    676: {"from": [category("Alpha Headquarters", r"gilbert")]},
    680: {"from": [category("Alpha Headquarters", r"liza")]},
    679: {"from": [category("Alpha Headquarters", r"graham")]},
    681: {"from": [category("Alpha Headquarters", r"cosmo")]},
    # hall of Animals. the plushies and the coins are named in the room
    # file; which of the three tables has banners, statues and flags is
    # guessed.
    805: {"from": [page("Hall of Animals", r"Animal Banners")]},
    806: {"from": [page("Hall of Animals", r"Alpha Statues")]},
    803: {"from": [page("Hall of Animals", r"Flags")]},
    807: {"from": [page("Hall of Animals", r"Giant Animal Plushies")]},
    817: {"from": [page("Hall of Animals", r"Animal Coins")]},

    # parties.
    61: {"from": [category("Jamaaliday Shop")], "music": False},
    138: {"from": [category("Jamaaliday Shop")], "music": True},
    709: {"from": [page("Giant Gift Pile (Shop)")]},
    67: {"from": [page("Dinner Shop")]},
    68: {"from": [page("Friendship Shop")]},
    70: {"from": [page("Heatwave Shop")]},
    71: {"from": [page("Leap Year Accessories")]},
    72: {"from": [page("Leap Year Den Items")]},
    74: {"from": [page("Lucky Shop")]},
    81: {"from": [page("Wolves Only Shop")]},
    83: {"from": [page("Horses Only Shop")]},
    84: {"from": [page("Horses Only Shop")], "music": False},
    90: {"from": [page("Horses Only Shop")], "music": True},
    82: {"from": [page("April Fools' Shop")]},
    216: {"from": [page("April Fools' Shop")]},
    87: {"from": [page("Atlantis Shop")]},
    88: {"from": [page("Atlantis Shop")]},
    92: {"from": [page("Spooky Shop")]},
    93: {"from": [page("Spooky Shop")], "music": False},
    94: {"from": [page("Spooky Shop")], "music": True},
    95: {"from": [page("Cruise Ship Shop")]},
    96: {"from": [page("Cruise Ship Shop")]},
    99: {"from": [page("Bunnies Only Shop")], "music": False},
    100: {"from": [page("Bunnies Only Shop")], "music": True},
    104: {"from": [page("Penguins Only Shop")], "music": False},
    106: {"from": [page("Penguins Only Shop")], "music": True},
    107: {"from": [category("Freedom Shop")]},
    108: {"from": [category("Freedom Shop")]},
    111: {"from": [page("Pets Only Shop")], "music": False},
    112: {"from": [page("Pets Only Shop")], "music": True},
    116: {"from": [page("Monkeys Only Shop")], "music": False},
    117: {"from": [page("Monkeys Only Shop")], "music": True},
    118: {"from": [page("AJ Birthday Shop")], "music": False},
    119: {"from": [page("AJ Birthday Shop")], "music": True},
    346: {"from": [page("AJ Birthday Shop")]},
    122: {"from": [page("Haunted Forest Shop")]},
    123: {"from": [page("Haunted Forest Shop")], "music": False},
    124: {"from": [page("Haunted Forest Shop")], "music": True},
    143: {"from": [page("New Year's Shop")]},
    144: {"from": [page("New Year's Shop")], "music": False},
    145: {"from": [page("New Year's Shop")], "music": True},
    161: {"from": [page("Jam Session Shop")]},
    164: {"from": [page("Jam Session Shop")], "music": False},
    163: {"from": [page("Jam Session Shop")], "music": True},
    191: {"from": [category("Play-As-Your-Pet Shop")], "music": False},
    192: {"from": [category("Play-As-Your-Pet Shop")], "music": False},
    193: {"from": [category("Play-As-Your-Pet Shop")], "music": True},
    238: {"from": [category("Beta Shop")]},
    271: {"from": [page("Bounce House Shop")]},
    324: {"from": [page("Cloud Shop")]},
    325: {"from": [page("Cloud Shop")]},
    345: {"from": [page("Schoolhouse Shop")]},
    150: {"from": [page("Paradise Shop")]},
    400: {"from": [category("Candy Shop")]},
    # one party room for every year's animal: all their shops together.
    399: {"from": [category(shop) for shop in NEW_YEARS]},
    # the Phantom Emporium's three rooms.
    816: {"from": [page("Phantom Emporium (Shop)")]},
    818: {"from": [page("Phantom Emporium (Shop)")]},
    819: {"from": [page("Phantom Emporium (Shop)")]},
}


def main(workdir, out_path=OUT):
    wiki, pages = download(workdir)
    ids = {}
    for kind in ("clothing", "den"):
        for title, def_id in wiki["ids"][kind].items():
            if def_id.isdigit():
                ids.setdefault(title.lower(), []).append((kind, int(def_id)))
    unknown = set()

    def matching(pattern, text):
        if not pattern:
            return True
        if pattern.startswith("!"):
            return not re.search(pattern[1:], text, re.I)
        return bool(re.search(pattern, text, re.I))

    def take(titles, name):
        return [item for title in titles if matching(name, title) for item in ids.get(title.lower(), [])]

    lists = {}
    for list_id, spec in sorted(LISTS.items()):
        now, former, shops = [], [], []
        for shop, where, heading, name in spec["from"]:
            shops.append(shop)
            if where == "category":
                now += take(wiki["shops"][shop]["now"], name)
                former += take(wiki["shops"][shop]["former"], name)
            else:
                for head, body in sections(pages[shop]):
                    if matching(heading, head):
                        found = names(latest_tab(body))
                        unknown.update(n for n in found if n and n.lower() not in ids and len(n) < 40)
                        now += take(found, name)
        entry = {"shop": " + ".join(shops) if len(shops) < 3 else shops[0] + " and others"}
        if "music" in spec:
            entry["music"] = spec["music"]
        for label, items in (("now", now), ("former", [item for item in former if item not in now])):
            unique = list(dict.fromkeys(items))
            entry[label] = {kind: [def_id for item_kind, def_id in unique if item_kind == kind and kind in spec.get("kinds", (kind,))]
                            for kind in ("clothing", "den")}
        lists[str(list_id)] = entry
        print("%4d  %-34s now %3d clothing %3d den   former %4d" % (
            list_id, entry["shop"][:34], len(entry["now"]["clothing"]), len(entry["now"]["den"]),
            len(entry["former"]["clothing"]) + len(entry["former"]["den"])))
    out = {"source": "AJ Classic Wiki (animaljam.fandom.com), read by tools/shop-stock.py", "lists": lists}
    with open(out_path, "w") as handle:
        handle.write(json.dumps(out, separators=(",", ":")).replace('"lists":{', '"lists":{\n').replace('}},"', '}},\n"') + "\n")
    print("\nnames on shop pages that are no item page (links to other pages, mostly):")
    print(", ".join(sorted(unknown)))


if __name__ == "__main__":
    if len(sys.argv) not in (2, 3):
        raise SystemExit(__doc__)
    main(*sys.argv[1:])
