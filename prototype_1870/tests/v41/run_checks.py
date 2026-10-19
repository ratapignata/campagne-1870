"""Additional existing regression checks and existing 20-turn simulation harnesses."""
import argparse, concurrent.futures, json, os, subprocess, time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
def run(godot,out,item):
    name,script,args,timeout=item
    runtime=out/'runtime'/name
    runtime.mkdir(parents=True,exist_ok=True)
    env=os.environ.copy();env.update(XDG_DATA_HOME=str(runtime),XDG_CONFIG_HOME=str(runtime/'config'),XDG_CACHE_HOME=str(runtime/'cache'))
    command=[godot,'--headless','--path',str(ROOT),'--script','res://tests/'+script+'.gd']
    if args:command+=['--']+args
    start=time.monotonic()
    with (out/(name+'.log')).open('w') as log:
        try:code=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,env=env,timeout=timeout).returncode
        except subprocess.TimeoutExpired:code=124
    text=(out/(name+'.log')).read_text()
    errors=[line for line in text.splitlines() if any(t in line for t in ['FAIL','SCRIPT ERROR','Parse Error','ERROR:'])]
    result={'test':name,'exit':code,'errors':errors,'seconds':time.monotonic()-start,'command':command}
    for f in (runtime/'1870-prototype-v02').glob('*.json'):
        if f.name in ['simulation.json','optimization.json','balance.json'] or f.name.startswith('compare_'):
            (out/(name+'_'+f.name)).write_bytes(f.read_bytes())
    (out/(name+'_result.json')).write_text(json.dumps(result,indent=2))
    print(name,'PASS' if code==0 and not errors else 'FAIL',round(result['seconds'],2),flush=True)
    return result

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--godot',required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--mode',choices=['extra','simulations','optimization'],required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
    if a.mode=='extra':
        names=['v38/test_artillery_budget','v38/test_reinforcements','v38/test_ui','v38/test_legacy_save','v39/test_lot1','v39/test_lot2','v39/test_capture_opportunity']
        jobs=[(n.replace('/','_'),n,[],300) for n in names]
    elif a.mode=='optimization':jobs=[('optimization','v41/test_optimization',[],1800)]
    else:
        jobs=[(m+'_'+str(s),'v41/test_comparison',[m,str(s)],3600) for s in [187037,187038] for m in ['medium','hard']]
        jobs += [(label,'v36/test_ai_active',[label],900) for label in ['C_turn12','E_final']]
    # Timing comparisons run alone. Simulation timings are not benchmark timings.
    with concurrent.futures.ThreadPoolExecutor(max_workers=1 if a.mode=='optimization' else 2) as ex:
        results=list(ex.map(lambda j:run(a.godot,a.out,j),jobs))
    (a.out/'results.json').write_text(json.dumps(results,indent=2))
    raise SystemExit(any(r['exit'] or r['errors'] for r in results))
