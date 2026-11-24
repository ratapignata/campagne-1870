"""Read-only screenshot analysis; optional Pillow dependency, no images rewritten.
Usage: python compare_brightness.py BEFORE_DIR AFTER_DIR OUTPUT_JSON
The weighted 0..255 RGB index is not a measurement of physical display brightness.
"""
import json
import sys
from pathlib import Path
from PIL import Image, ImageStat

def luma(image, rect):
    x, y, width, height = rect
    mean = ImageStat.Stat(image.crop((x, y, x + width, y + height)).convert('RGB')).mean
    return sum(value * weight for value, weight in zip(mean, (0.2126, 0.7152, 0.0722)))

before, after, output = map(Path, sys.argv[1:])
b = json.loads((before / 'metrics.json').read_text())
a = json.loads((after / 'metrics.json').read_text())
assert len(b['captures']) == len(a['captures']) == 6
report = []
for old, new in zip(b['captures'], a['captures']):
    for field in ('case', 'state_hash', 'force_strips', 'left_card_rect', 'artwork', 'focus', 'zoom'):
        assert old[field] == new[field], (old['case'], field)
    with Image.open(before / (old['case'] + '.png')) as im0, Image.open(after / (new['case'] + '.png')) as im1:
        row = {'case': old['case'],
               'map_luminance_before': luma(im0, (0, 92, 1280, 448)),
               'map_luminance_after': luma(im1, (0, 92, 1280, 448)),
               'unit_mean_before': sum(luma(im0, v['rect']) for v in old['artwork'].values()) / len(old['artwork']),
               'unit_mean_after': sum(luma(im1, v['rect']) for v in new['artwork'].values()) / len(new['artwork'])}
        assert row['map_luminance_after'] > row['map_luminance_before'], row
        assert row['unit_mean_after'] > row['unit_mean_before'], row
        report.append(row)
output.write_text(json.dumps(report, indent=2) + '\n')
print('BRIGHTER MAP AND COUNTERS: 6/6 paired scenes; states and force strips identical.')
