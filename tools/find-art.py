#!/usr/bin/env python3
"""Finds artwork among the CDN's media files that the game used to be told
about by lists on the official servers: Jam-A-Gram cards, Jammer Wall
wallpapers and wall stickers. Prints the media ids of each.

  python3 tools/find-art.py [firstId] [lastId]      (default 1 to 9500)

A media file is a SWF, zlib ("CWS") or LZMA ("ZWS") compressed. What tells
them apart is the names of the clips inside:

  card        a "msgTxt" text field and a "stamp" clip (ecard.ECardImageBase)
  wallpaper   a "postStatus" clip (playerWall.PlayerWallGui.onWallDecorItemLoaded)
  sticker     the ones found carry "sticker" in a symbol name

That overshoots a little (a few windows of the game have the same names
inside), so the results were looked at, one picture each, before going into
lib/ecard-art.json and lib/wall-art.json. Two things had to be done by eye
altogether: stamps are plain pictures with nothing to tell them by (ids
10-23 are what sits next to the first cards), and each wallpaper's button in
the wall's "customize" popup is a separate file, usually numbered right after
or right before its batch of wallpapers.

It downloads every file in the range (about 250 MB) without keeping any.
"""
import concurrent.futures
import hashlib
import lzma
import struct
import sys
import urllib.request
import zlib

CONTENT = "https://ajcontent.akamaized.net/"
DEPLOY_VERSION = "1830"


def hashed(name):
    """LoaderCache.hashItV2, as in lib/cdn.js."""
    salted = "W3 7r4Ck h4X0r3rs" + name
    out = ""
    for index, char in enumerate(salted):
        out = out + char if index % 2 == 0 else char + out
    return hashlib.md5(out.encode()).hexdigest()


def inflate(data):
    if data[:3] == b"CWS":
        return zlib.decompress(data[8:])
    if data[:3] == b"ZWS":
        # ZWS: "ZWS", version, uncompressed length, compressed length, LZMA
        # properties, data. the .lzma format wants properties, length, data.
        size = struct.unpack("<I", data[4:8])[0] - 8
        return lzma.decompress(data[12:17] + struct.pack("<Q", size) + data[17:], format=lzma.FORMAT_ALONE)
    return data


def kinds(media_id):
    url = "%s%s/media/%s?v=3" % (CONTENT, DEPLOY_VERSION, hashed(str(media_id)))
    try:
        request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        body = inflate(urllib.request.urlopen(request, timeout=60).read())
    except Exception:
        return media_id, []
    found = []
    if b"postStatus" in body:
        found.append("wallpaper")
    elif b"msgTxt" in body and b"stamp" in body:
        found.append("card")
    if b"sticker" in body and b"postStatus" not in body:
        found.append("sticker")
    return media_id, found


def main():
    first = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    last = int(sys.argv[2]) if len(sys.argv) > 2 else 9500
    results = {"card": [], "wallpaper": [], "sticker": []}
    with concurrent.futures.ThreadPoolExecutor(16) as pool:
        for media_id, found in pool.map(kinds, range(first, last + 1)):
            for kind in found:
                results[kind].append(media_id)
    for kind, ids in results.items():
        print(kind, ids)


if __name__ == "__main__":
    main()
