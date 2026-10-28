# every web address a SWF players load could reach out to, checked against
# .github/allowed-hosts.json ("swf"). the game files are what the client runs,
# so a host that shows up in one of them for the first time fails the check
# until somebody looks at it and adds it to the list.
#
#   python3 .github/scripts/swf-hosts.py [--list] <file.swf> ...
#
# --list prints the hosts found instead of checking them.

import json
import lzma
import re
import sys
import zlib
from pathlib import Path

HOST = re.compile(rb"https?://([A-Za-z0-9.-]+)")


def body(data):
    """the SWF's bytes after the 8-byte header, uncompressed."""
    kind = data[:3]
    if kind == b"FWS":
        return data[8:]
    if kind == b"CWS":
        return zlib.decompress(data[8:])
    if kind == b"ZWS":
        # sig(3) version(1) length(4) lzma length(4) props(5) data: rebuilt as
        # an .lzma stream of unknown size
        return lzma.LZMADecompressor(lzma.FORMAT_ALONE).decompress(data[12:17] + bytes([0xFF] * 8) + data[17:])
    raise ValueError("not a SWF")


def hosts(path):
    found = set()
    for match in HOST.finditer(body(path.read_bytes())):
        host = match.group(1).decode("ascii").lower().strip(".-")
        if "." in host:
            found.add(host)
    return found


def main(args):
    listing = "--list" in args
    files = [Path(arg) for arg in args if arg != "--list"]
    allowed = set(json.loads(Path(".github/allowed-hosts.json").read_text())["swf"]) if not listing else set()
    failed = False
    for path in files:
        try:
            found = hosts(path)
        except (ValueError, lzma.LZMAError, zlib.error) as err:
            print(f"::error file={path}::cannot read {path}: {err}")
            failed = True
            continue
        if listing:
            print(f"{path}: {', '.join(sorted(found)) or '(none)'}")
            continue
        for host in sorted(found - allowed):
            print(f"::error file={path}::{path} names {host}, which is not in .github/allowed-hosts.json")
            failed = True
    if not listing and not failed:
        print(f"{len(files)} SWFs checked: every web address in them is on the list")
    return 1 if failed else 0


sys.exit(main(sys.argv[1:]))
