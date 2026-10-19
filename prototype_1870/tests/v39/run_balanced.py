import concurrent.futures,json,os,subprocess,sys
from pathlib import Path
p=Path(__file__).resolve().parents[2];g=str(Path(sys.argv[1]).resolve());out=p/'tests/results/0839/simulations_balanced';out.mkdir(parents=True,exist_ok=True)
def run(item):
 mode,seed=item;name=f'{mode}_{seed}';runtime=Path('/tmp/v39-sim-balanced')/name;runtime.mkdir(parents=True,exist_ok=True)
 env=os.environ.copy();env['XDG_DATA_HOME']=str(runtime)
 with (out/f'{name}.log').open('w') as log:
  try:r=subprocess.run([g,'--headless','--path',str(p),'--script','res://tests/v39/simulate.gd','--',mode,str(seed)],stdout=log,stderr=subprocess.STDOUT,env=env,timeout=1500);code=r.returncode
  except subprocess.TimeoutExpired:code=124
 report=runtime/'godot/app_userdata/1870-prototype-v02/simulation.json'
 # custom user directory lies directly under XDG_DATA_HOME
 if not report.exists():report=runtime/'1870-prototype-v02/simulation.json'
 if report.exists():(out/f'{name}.json').write_bytes(report.read_bytes())
 checkpoint=report.parent/'checkpoint.json'
 if checkpoint.exists():(out/f'{name}_save.json').write_bytes(checkpoint.read_bytes())
 result={'mode':mode,'seed':seed,'exit':code};print(result,flush=True);return result
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
 results=list(pool.map(run,[(m,s) for s in [187037,187038] for m in ['hard']]))
(out/'runs.json').write_text(json.dumps(results,indent=2))
