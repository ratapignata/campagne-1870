#!/usr/bin/env python3
"""Identical 14-unit fixtures: French medium versus three Prussian modes, two seeds."""
import argparse, concurrent.futures, json, os, pathlib, subprocess
p=argparse.ArgumentParser();p.add_argument('--godot',required=True);p.add_argument('--output-dir',type=pathlib.Path,required=True);p.add_argument('--french-mode',choices=['easy','medium','hard'],default='medium');p.add_argument('--modes',nargs='+',choices=['easy','medium','hard'],default=['easy','medium','hard']);p.add_argument('--seeds',nargs='+',type=int,default=[187037,187038]);a=p.parse_args()
project=pathlib.Path(__file__).resolve().parents[2];a.output_dir.mkdir(parents=True,exist_ok=True)
def run(item):
 mode,seed=item;out=a.output_dir/f'{mode}-{seed}';out.mkdir(parents=True,exist_ok=True)
 env=os.environ.copy();env.update(XDG_DATA_HOME=str(out/'data'),XDG_CONFIG_HOME=str(out/'config'),XDG_CACHE_HOME=str(out/'cache'))
 command=[a.godot,'--headless','--path',str(project),'--script','res://tests/v38/test_comparison.gd','--',mode,str(seed),a.french_mode]
 with (out/'run.log').open('w') as log:r=subprocess.run(command,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=2400)
 text=(out/'run.log').read_text();errors=[l for l in text.splitlines() if any(x in l for x in ['FAIL','SCRIPT ERROR','ERROR:'])]
 result={'mode':mode,'french_mode':a.french_mode,'seed':seed,'exit':r.returncode,'errors':errors};print(json.dumps(result),flush=True);return result
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:results=list(pool.map(run,[(m,s) for s in a.seeds for m in a.modes]))
(a.output_dir/'results.json').write_text(json.dumps(results,indent=2));raise SystemExit(int(any(r['exit'] or r['errors'] for r in results)))
