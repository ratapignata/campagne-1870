"""Generate visual road edges from the existing provisional sector polylines.
No terrain costs, river crossing or save fingerprints are changed.
"""
from pathlib import Path
import json,math
root=Path(__file__).resolve().parents[2]
s=json.loads((root/'development/historical05/sector.json').read_text())
p=json.loads((root/'packs/1870/prototype.json').read_text())
candidates=[t for t in s['tiles'] if t['active']]
river={tuple(sorted((e['a'],e['b']))) for e in p['map']['river_edges'] if not e['bridge']}
edges=set(); paths=[]
for road in s['roads_xy']:
 path=[]
 for a,b in zip(road,road[1:]):
  steps=math.ceil(math.dist(a,b)/.025)
  for k in range(steps+1):
   pos=[a[j]+(b[j]-a[j])*k/steps for j in [0,1]]
   t=min(candidates,key=lambda t:math.dist(pos,t['xy']))
   if math.dist(pos,t['xy'])>.32:continue
   if not path or path[-1]!=t['id']:path.append(t['id'])
 paths.append(path)
 for a,b in zip(path,path[1:]):
  key=tuple(sorted((a,b)))
  if b in s['adjacency'][str(a)] and key not in river:edges.add(key)
# A single road crossing is represented in this test scenario.
for e in p['map']['river_edges']:
 if e['bridge']:edges.add(tuple(sorted((e['a'],e['b']))))
data={'scenario_id':p['id'],'status':'ADAPTATION GAMEPLAY','note':'Tracé visuel issu des polylignes provisoires du secteur 05. Les routes sont interrompues aux traversées sans pont dans cet exercice. Aucun effet supplémentaire sur les coûts de déplacement.','road_edges':[list(e) for e in sorted(edges)]}
(root/'packs/1870/sauer_roads.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
print('Road paths:',paths,'edges:',len(edges))
