extends "res://tests/test_ai_compat0833.gd"
const Prior=preload("res://war_engine/ai/v4316_ai.gd")
func scenario(kind: String):
 var p=data.duplicate(true);p.units=[];p.rules.fog.enabled=false;p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[];p.objectives=p.objectives.slice(0,1)
 var ids=["art_fr_Pellé0","fr_7","qg_fr_Pellé","pru_36","pru_37","qg_pr_Sandrart"]
 var cells=[[11,5],[11,7],[10,2],[11,10],[11,11],[11,15]]
 for id in ids:
  for u in data.units:
   if u.id==id:p.units.append(u.duplicate(true))
 for n in range(p.units.size()):p.units[n].cell=cells[n];p.units[n].arrival_turn=1
 return p
func attacker(e) -> Dictionary:
 # Scripted active attacker, same for both policies, all-visible isolated fixture.
 for n in range(e.state.units.size()):
  var u=e.state.units[n]
  if int(u.side)!=1 or not e.can_act(n) or e.headquarters(n) or u.morale=="routed":continue
  for j in range(e.state.units.size()):
   if int(e.state.units[j].side)!=0:continue
   if e.assault_status(n,j)=="ok" and e.attack_power_against(n,j)>=e.defence_power_against(j,n)*1.25:return {"kind":"assault","unit":u.id,"target":e.state.units[j].id}
  for j in range(e.state.units.size()):
   if e.fire_status(n,j)=="ok":return {"kind":"fire","unit":u.id,"target":e.state.units[j].id}
  var reach=e.reach(n);var best=-1;var value=-INF;var start=e.unit_cell(u)
  for dest in reach.costs:
   if dest==start or e.unit_at(dest)>=0:continue
   var distance=999
   for foe in e.state.units:
    if int(foe.side)==0 and int(foe.strength)>0:distance=mini(distance,e.distance(dest,e.unit_cell(foe)))
   var score=-float(distance)*20.0-float(reach.costs[dest])
   if distance<=2 and int(u.ap)-int(reach.costs[dest])>=8:score+=40.0
   if score>value:value=score;best=dest
  if best>=0:
   var path=[best]
   while reach.parents.has(path[0]):path.push_front(reach.parents[path[0]])
   return {"kind":"move","unit":u.id,"path":path}
 return {"kind":"end"}
func report_state(e):
 var count={"covered":0,"entrenched":0,"living":0,"hq":0,"double_cut":0,"routed":0,"strength":0}
 for n in range(e.state.units.size()):
  var u=e.state.units[n]
  if int(u.side)!=0 or not e.alive(n):continue
  count.living+=1;count.strength+=int(u.strength)
  if e.headquarters(n):count.hq+=1
  if not u.command_ok and not u.supply_ok:count.double_cut+=1
  if u.morale=="routed":count.routed+=1
  if not e.headquarters(n) and not e.artillery(n) and not e.cavalry(n):
   if float(e.pack.terrains[e.pack.map.tiles[e.unit_cell(u)]].fire_received)<=0.65:count.covered+=1
   if u.entrenched:count.entrenched+=1
 return count
func _initialize():
 var args=OS.get_cmdline_user_args();var policy=args[0];var kind=args[1];var out=args[2];var seed_value=int(args[3]);var last_turn=int(args[4]);var reach=int(args[5]);var style=int(args[6])
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var pack=scenario(kind)
 if reach==3:pack.weapons.chassepot.range=3;pack.weapons.chassepot.distance_factors=pack.weapons.chassepot.distance_factors.slice(0,3)
 var e=Rules.new(pack);e.new_game(1,"hard");e.state.seed=seed_value;e.state.ai_style=style
 e.state.units[0].deployed=true;e.state.units[1].entrenched=true
 for n in [1,3,4]:e.state.units[n].formation="line"
 e.refresh_support(false);e.refresh_intel()
 var french=bot();french.profiles=profiles;var prussian=Prior.new();prussian.profiles=profiles
 var report={"policy":policy,"scenario":kind,"seed":seed_value,"style":style,"chassepot_range":reach,"last_turn":last_turn,"initial_force":[e.initial_force(0),e.initial_force(1)],"initial_units":e.state.units.size(),"protocol":"Targeted six-unit gun-lane fixture: one original-stat French deployed gun on an objective, a fixed entrenched friendly infantry screen blocking its LOS, HQ, two original-stat active scripted Prussian attackers and HQ. Plain test terrain, one objective, all visible, six turns; not a full battle or user replay. Same rules/AP/ammo/support, initial positions and scripted attacker for Normal/Hard. Only the gun is controlled by the French policy; screen retains reactions.","phases":[],"actions":[],"complete":false}
 check(e.validate(e.state),"initial state valid")
 var started=Time.get_ticks_msec()
 while not e.state.finished and int(e.state.turn)<=last_turn and failures==0:
  var side=int(e.state.side);var turn=int(e.state.turn)
  if side==0:
   for n in range(e.state.units.size()):
    if int(e.state.units[n].side)==0 and not e.artillery(n):e.state.units[n].done=true
  var counts={};var ended=false;var event_start=e.state.events.size();var clock=Time.get_ticks_msec()
  for step in range(500):
   var seen=[]
   for n in range(e.state.units.size()):
    if int(e.state.units[n].side)!=side and e.alive(n):seen.append(n)
   var view=e.observation(side,seen);view.state.ai_difficulty=policy if side==0 else "hard";var stamp=Time.get_ticks_msec();var action=french.choose(view) if side==0 else attacker(e)
   report.actions.append({"side":side,"turn":turn,"action":action,"ms":Time.get_ticks_msec()-stamp})
   check(dispatch(e,action),"legal order "+JSON.stringify(action));check(e.validate(e.state),"valid state after order")
   counts[action.kind]=int(counts.get(action.kind,0))+1
   if action.kind=="end" or failures>0:ended=action.kind=="end";break
  check(ended,"phase completed without action cap")
  var cannon=0
  for n in range(event_start,e.state.events.size()):
   var event=e.state.events[n]
   if int(event.side)==side and event.kind=="fire" and event.cannon:cannon+=1
  report.phases.append({"side":side,"turn":turn,"orders":counts,"cannon":cannon,"french":report_state(e),"losses":[e.losses(0),e.losses(1)],"prisoners":[e.prisoners(0),e.prisoners(1)],"objectives":e.state.objective_owners.duplicate(),"ms":Time.get_ticks_msec()-clock})
  print("PHASE ",policy," ",kind," ",seed_value," ",JSON.stringify(report.phases[-1]))
  report.checks=checks;report.failures=failures
  var file=FileAccess.open(out,FileAccess.WRITE);file.store_string(JSON.stringify(report));file.close()
 report.complete=failures==0 and (e.state.finished or int(e.state.turn)>last_turn);report.finished=e.state.finished
 report.result=e.result_for(1);report.history=e.state.battle_history;report.checks=checks;report.failures=failures;report.elapsed_ms=Time.get_ticks_msec()-started
 var file=FileAccess.open(out,FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
 file=FileAccess.open(out+".state.json",FileAccess.WRITE);file.store_string(JSON.stringify(e.state));file.close()
 print("DEFENCE SIM ",checks-failures,"/",checks);quit(1 if failures else 0)
