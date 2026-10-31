#!/usr/bin/env python3
"""Compare the experiment with its immutable stable Git reference (read-only)."""
import argparse, hashlib, json, re, subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("--reference", default="34d8f73")
parser.add_argument("--output")
parser.add_argument("--baseline-directory", type=Path, help="Extracted stable V43.15 sources, usable without Git")
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
def git(*cmd):
    return subprocess.check_output(["git", "-C", str(root), *cmd])
if args.baseline_directory:
    stable_root = args.baseline_directory.resolve()
    reference = str(stable_root)
    def baseline(name):
        return (stable_root / name).read_bytes()
    files = sorted(str(p.relative_to(stable_root)) for p in stable_root.rglob("*")
                   if p.is_file() and ".git" not in p.relative_to(stable_root).parts
                   and ".godot" not in p.relative_to(stable_root).parts)
else:
    reference = git("rev-parse", args.reference).decode().strip()
    files = git("ls-tree", "-r", "--name-only", reference).decode().splitlines()
    def baseline(name):
        return git("show", reference + ":" + name)
allowed = {"project.godot", "export_presets.cfg", "packs/1870/fr.json",
           "war_engine/presentation/main.gd", "war_engine/presentation/map_view.gd"}
changed = []
identical = []
for name in files:
    old = baseline(name)
    current = root / name
    if not current.exists() or current.read_bytes() != old:
        changed.append(name)
    else:
        identical.append(name)
assert set(changed) <= allowed, "Unexpected changes to stable files: " + str(set(changed) - allowed)
functions = {}
for name, permitted in {
    "war_engine/presentation/main.gd": {"panel", "button", "build_ui", "unit_heading", "layout_cards"},
    "war_engine/presentation/map_view.gd": {"_ready", "_draw", "counter_back", "horseman", "soldier", "cannon", "draw_contact", "selection_outline"}
}.items():
    def split_functions(source):
        chunks = re.split(r"(?=^func )", source, flags=re.M)
        return {re.match(r"func (\w+)", c).group(1): c.rstrip() for c in chunks if c.startswith("func ")}
    old = split_functions(baseline(name).decode())
    new = split_functions((root / name).read_text())
    assert set(old) == set(new), "Function added/deleted in " + name
    delta = {k for k in old if old[k] != new[k]}
    assert delta <= permitted, "Unexpected function edits: " + str(delta - permitted)
    functions[name] = {"total": len(old), "identical": len(old) - len(delta), "cosmetic_changes": sorted(delta)}
old_texts = json.loads(baseline("packs/1870/fr.json"))
new_texts = json.loads((root / "packs/1870/fr.json").read_text())
assert {k: v for k, v in old_texts.items() if k != "badge"} == {k: v for k, v in new_texts.items() if k != "badge"}
report = {"reference": reference, "tracked_files_identical": len(identical), "changed_existing_files": changed,
          "functions": functions, "scenario_sha256": hashlib.sha256((root / "packs/1870/regimental_trial_v43.json").read_bytes()).hexdigest(),
          "result": "PASS", "scope": "No modifications to AI, core, platform, map data, scenes or existing combat animations."}
print(json.dumps(report, indent=2))
if args.output:
    Path(args.output).write_text(json.dumps(report, indent=2) + "\n")
