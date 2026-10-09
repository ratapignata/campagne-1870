#!/usr/bin/env python3
"""Run the chronological 81-unit battle using Godot 4.5.1, retaining saves and logs."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--godot', default=shutil.which('godot'))
parser.add_argument('--output-dir', type=Path)
parser.add_argument('--resume', action='store_true')
args = parser.parse_args()
if not args.godot:
    parser.error('Specify --godot /path/to/Godot_4.5.1')
project = Path(__file__).resolve().parents[2]
output = (args.output_dir or Path(tempfile.mkdtemp(prefix='1870-v37-full-'))).resolve()
output.mkdir(parents=True, exist_ok=True)
env = os.environ.copy()
env.update(XDG_DATA_HOME=str(output / 'data'), XDG_CACHE_HOME=str(output / 'cache'),
           XDG_CONFIG_HOME=str(output / 'config'))
version = subprocess.check_output([args.godot, '--version'], env=env, text=True).strip()
if not version.startswith('4.5.1.'):
    parser.error('Godot 4.5.1 required: ' + version)
command = [args.godot, '--headless', '--path', str(project), '--script',
           'res://tests/v37/test_full_battle.gd']
if args.resume:
    command += ['--', '--resume']
print('Live log and checkpoints:', output, flush=True)
with (output / ('resume.log' if args.resume else 'battle.log')).open('w') as log:
    result = subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT)
print('Godot exit:', result.returncode, flush=True)
raise SystemExit(result.returncode)
