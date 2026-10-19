from pathlib import Path
import json,collections
r=Path(__file__).resolve().parents[2];d=json.loads((Path(__file__).parent/'map_candidate.json').read_text());p=json.loads((r/'packs/1870/three_objectives.json').read_text())
p.update(id='historical_terrain_trial0825',version='0.8.25',description_key='historical_trial_detail',historical_status='ADAPTATION_GAMEPLAY',historical_note='Essai sur la carte candidate de l’atelier 11. Forces, déploiement, horaires et objectifs simplifiés ; pas une reconstitution de la bataille.')
p['map'].update(tiles=[t['base_terrain'] for t in d['tiles']],elevations=[t['level'] for t in d['tiles']],road_edges=d['road_edges'],north_left=True,neighbor_distance_m=350,river_edges=[dict(a=e['a'],b=e['b'],bridge='C3' in e['crossings']) for e in d['river_edges']],view={'focus_cell':[16,9],'zoom':.72},labels=[dict(cell=[x['cell_id']%30,x['cell_id']//30],text=x['name'])for x in d['labels']]+[dict(cell=[18,6],text='Niederwald')])
p['rules']['turns']=18;p['rules']['start_hour']=8
p['objectives']=[dict(id=o['id'],cell=[o['cell_id']%30,o['cell_id']//30],points=3-i,initial_owner=0,name_key='goal_historical_'+o['id'])for i,o in enumerate(d['objectives'])];p['objective']={'cell':p['objectives'][0]['cell'],'points':3}
positions=[[11,5],[15,5],[18,7],[21,9],[12,12],[16,12],[20,13],[23,14],[14,6],[18,13],[23,8],[25,14],[14,4],[18,16]]
used=set()
for u,pos in zip(p['units'],positions):
 desired=pos[1]*30+pos[0];bank='west' if u['side']==0 else 'east'
 allowed=[t for t in d['tiles'] if t['id']not in used and t['bank']==bank and t['base_terrain']!='forest']
 tile=min(allowed,key=lambda t:abs(t['q']-pos[0])+abs(t['r']-pos[1]));u['cell']=[tile['q'],tile['r']];used.add(tile['id'])
# Fixed wagons at the rear, linked to the existing road graph on their bank.
p['rules']['support']['supply_sources']=[[[11,1]],[[18,19]]];p['rules']['support']['rear_rows']=[0,19];p['map']['supply_road_paths']=[]
for side,seeds in enumerate(p['rules']['support']['supply_sources']):
 bank='west' if side==0 else 'east'
 for q,row in seeds:
  start=row*30+q;assert d['tiles'][start]['bank']==bank
  targets={n for e in p['map']['road_edges'] for n in e if d['tiles'][n]['bank']==bank};queue=collections.deque([start]);prev={start:None};end=None
  while queue:
   u=queue.popleft()
   if u in targets:end=u;break
   for v in d['adjacency'][str(u)]:
    if v not in prev and d['tiles'][v]['bank']==bank:prev[v]=u;queue.append(v)
  assert end is not None
  path=[end]
  while path[0]!=start:path.insert(0,prev[path[0]])
  for a,b in zip(path,path[1:]):
   edge=sorted([a,b])
   if edge not in p['map']['road_edges']:p['map']['road_edges'].append(edge)
  p['map']['supply_road_paths'].append({'side':side,'cells':path,'historical_status':'ADAPTATION_GAMEPLAY'})
p['map']['roads_note']='Tracés candidats de l’atelier11 ; raccords des chariots ajoutés pour cet essai.'
(r/'packs/1870/historical_trial.json').write_text(json.dumps(p,ensure_ascii=False,indent=2)+'\n')
print('Units',[(u['id'],u['cell'])for u in p['units']])
