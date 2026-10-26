import json
from pathlib import Path
from collections import Counter
root=Path('/workspace/v4311/from_start')
pack=json.loads(Path('/workspace/v43_audit/prototype_1870/packs/1870/regimental_trial_v43.json').read_text())
unit={u['id']:u for u in pack['units']}
results={}
for name in ['result','reference','defended']:
 d=json.loads((root/(name+'.json')).read_text())
 assert d['complete'] and d['failures']==0 and len(d['phases'])==20,name
 shots=[Counter(),Counter()];totals=[Counter(),Counter()]
 for a in d['actions']:
  side=a['side'];cmd=a['decision'];totals[side][cmd['kind']]+=1
  if cmd['kind']=='fire':shots[side]['artillery' if pack['weapons'][unit[cmd['unit']]['weapon']].get('requires_deployment',False) else pack['weapons'][unit[cmd['unit']]['weapon']].get('unit_type','infantry')]+=1
 results[name]={'version':d['version'],'protocol':d['protocol'],'seed':d['seed'],'style':d['style'],'checks':d['checks'],'failures':d['failures'],'completed_turns':10,'first_prussian_occupation':d['first_prussian_occupation'],'end_turn_10':d['phases'][-1],'totals':totals,'shots_by_type':shots,'phases':d['phases'],'elapsed_ms':d['elapsed_ms']}
(root/'summary.json').write_text(json.dumps(results,indent=2,ensure_ascii=False))
print(json.dumps({k:{x:v[x] for x in ['first_prussian_occupation','end_turn_10','checks','totals','shots_by_type']} for k,v in results.items()},ensure_ascii=False,indent=2))
