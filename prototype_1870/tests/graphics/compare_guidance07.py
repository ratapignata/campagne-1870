#!/usr/bin/env python3
"""Read actual Godot images; compare state, strength strips, header and brightness."""
import argparse
import json
from pathlib import Path
from PIL import Image, ImageChops, ImageStat

parser = argparse.ArgumentParser()
parser.add_argument("before", type=Path)
parser.add_argument("after", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
old = json.loads((args.before / "metrics.json").read_text())
new = json.loads((args.after / "metrics.json").read_text())
assert len(old["captures"]) == len(new["captures"]) == 8
rows = []
for a, b in zip(old["captures"], new["captures"]):
    assert a["case"] == b["case"]
    name = a["case"]
    restored_flags = []
    with Image.open(args.before / (name + ".png")) as im0, Image.open(args.after / (name + ".png")) as im1:
        before, after = im0.convert("RGB"), im1.convert("RGB")
        header_equal = ImageChops.difference(before.crop((0, 0, 1280, 92)), after.crop((0, 0, 1280, 92))).getbbox() is None
        mean0 = ImageStat.Stat(before.crop((0, 92, 1280, 540))).mean
        mean1 = ImageStat.Stat(after.crop((0, 92, 1280, 540))).mean
        # The old full selection border covered the left three pixels of a
        # neighbouring tricolour in this fixed HQ fixture. The new corners expose
        # that flag. Keep a strict comparison of the complete numeric region.
        for uid in a["force_strips"]:
            if a["force_strips"][uid] == b["force_strips"][uid]:
                continue
            assert name == "isolement" and uid == "fr_5" and a["zoom"] == 1.0
            assert a["artwork"][uid] == b["artwork"][uid]
            x, y, _, _ = a["artwork"][uid]["rect"]
            complete = ImageChops.difference(before.crop((x+4, y+41, x+47, y+50)), after.crop((x+4, y+41, x+47, y+50))).getbbox()
            assert complete is not None and complete[2] <= 3, complete
            numeric = (x+16, y+41, x+47, y+50)
            assert ImageChops.difference(before.crop(numeric), after.crop(numeric)).getbbox() is None
            restored_flags.append(uid)
    row = {"case": name, "state_identical": a["state_hash"] == b["state_hash"],
           "force_strips_identical": a["force_strips"] == b["force_strips"],
           "strip_count": len(a["force_strips"]), "header_pixel_identical": header_equal,
           "restored_neighbour_flags": restored_flags, "numeric_force_identical": True,
           "card_rectangle_identical": a["left_card_rect"] == b["left_card_rect"],
           "map_rgb_mean_before": mean0, "map_rgb_mean_after": mean1}
    assert all(row[k] for k in ("state_identical", "numeric_force_identical", "header_pixel_identical", "card_rectangle_identical")), row
    rows.append(row)
args.output.write_text(json.dumps(rows, indent=2) + "\n")
print("PASS: eight identical states/headers,", sum(r["strip_count"] for r in rows), "identical numeric force regions; one neighbouring flag uncovered, card geometry preserved.")
