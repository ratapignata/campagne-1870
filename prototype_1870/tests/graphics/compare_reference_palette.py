"""Read-only screenshot comparison with stable V43.15; optional Pillow dependency.
Usage: python compare_reference_palette.py STABLE_DIR TRIAL_DIR OUTPUT_JSON
RGB indices are not measurements of physical screen brightness.
"""
import json
import sys
from pathlib import Path
from PIL import Image, ImageStat
stable, trial, output = map(Path, sys.argv[1:])
a = json.loads((stable / 'metrics.json').read_text())
b = json.loads((trial / 'metrics.json').read_text())
def index(image, rect):
    x, y, w, h = rect
    mean = ImageStat.Stat(image.crop((x, y, x + w, y + h)).convert('RGB')).mean
    return sum(v * weight for v, weight in zip(mean, (.2126, .7152, .0722)))
rows = []
assert len(a['captures']) == len(b['captures']) == 6
for old, new in zip(a['captures'], b['captures']):
    for key in ('case', 'state_hash', 'force_strips', 'artwork', 'focus', 'zoom', 'left_card_rect'):
        assert old[key] == new[key], (old['case'], key)
    with Image.open(stable / (old['case'] + '.png')) as p, Image.open(trial / (new['case'] + '.png')) as q:
        rows.append({'case': old['case'], 'stable_map': index(p, (0, 92, 1280, 448)),
                     'trial_map': index(q, (0, 92, 1280, 448)),
                     'stable_unit': sum(index(p, v['rect']) for v in old['artwork'].values()) / len(old['artwork']),
                     'trial_unit': sum(index(q, v['rect']) for v in new['artwork'].values()) / len(new['artwork'])})
output.write_text(json.dumps(rows, indent=2) + '\n')
print('Stable/trial reference comparison: 6/6 states and force strips match; RGB indices recorded.')
