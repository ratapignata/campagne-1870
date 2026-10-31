#!/usr/bin/env python3
"""Read-only comparison of actual Godot captures from two experimental versions."""
import argparse
import json
from pathlib import Path
from PIL import Image, ImageChops

parser = argparse.ArgumentParser()
parser.add_argument("before", type=Path)
parser.add_argument("after", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
old = json.loads((args.before / "metrics.json").read_text())
new = json.loads((args.after / "metrics.json").read_text())
assert len(old["captures"]) == len(new["captures"]) == 6
rows = []
for a, b in zip(old["captures"], new["captures"]):
    assert a["case"] == b["case"]
    name = a["case"]
    with Image.open(args.before / (name + ".png")) as before, Image.open(args.after / (name + ".png")) as after:
        region = (0, 92, 1280, 540)
        identical = ImageChops.difference(before.convert("RGB").crop(region), after.convert("RGB").crop(region)).getbbox() is None
    row = {"case": name, "state_identical": a["state_hash"] == b["state_hash"],
           "force_strips_identical": a["force_strips"] == b["force_strips"],
           "strip_count": len(a["force_strips"]), "map_pixel_identical": identical,
           "card_rectangle_identical": a["left_card_rect"] == b["left_card_rect"]}
    assert all(row[k] for k in ("state_identical", "force_strips_identical", "map_pixel_identical", "card_rectangle_identical")), row
    rows.append(row)
args.output.write_text(json.dumps(rows, indent=2) + "\n")
print("PASS: six identical maps/states,", sum(r["strip_count"] for r in rows), "identical strength strips; card geometry preserved.")
