extends "res://tests/test_ai_compat0833.gd"
const Prior=preload("res://tests/v43/reference_tactical_ai_v4315.gd")
func scenario(kind: String):
 if kind=="full":return data.duplicate(true)
 var p=data.duplicate(true);p.units=[]
 var ids=["fr_6","fr_7","fr_8","fr_9","fr_10","fr_14","fr_15","fr_17","qg_fr_Pellé","qg_fr_Raoult","qg_fr_Lartigue","art_fr_Pellé0","art_fr_Raoult0","pru_36","pru_37","pru_38","pru_39","pru_40","pru_41","pru_42","pru_43","pru_54","pru_55","qg_pr_Sandrart","qg_pr_Schmidt","qg_pr_Schachtmeyer","art_pr_Sandrart0","art_pr_Schmidt0","art_pr_Schachtmeyer0"]
 var cells=[[13,10],[12,9],[14,9],[12,8],[14,8],[18,6],[18,7],[20,6],[13,7],[17,4],[20,4],[11,8],[17,6],[12,13],[13,13],[14,13],[12,14],[13,14],[14,14],[11,14],[15,14],[22,5],[20,3],[12,16],[15,16],[22,8],[11,15],[15,15],[22,9]]
 for id in ids:
  for u in data.units:
   if u.id==id:p.units.append(u.duplicate(true))
 for n in range(p.units.size()):p.units[n].cell=cells[n];p.units[n].arrival_turn=1
 return p
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
 var args=OS.get_cmdline_user_args();var policy=args[0];var kind=args[1];var out=args[2];var seed_value=int(args[3]);var last_turn=int(args[4])
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=Rules.new(scenario(kind));e.new_game(1,"hard");e.state.seed=seed_value;e.state.ai_style=0
 var french=Prior.new() if policy=="reference" else bot();french.profiles=profiles;var prussian=Prior.new();prussian.profiles=profiles
 var report={"policy":policy,"scenario":kind,"seed":seed_value,"style":0,"last_turn":last_turn,"initial_force":[e.initial_force(0),e.initial_force(1)],"initial_units":e.state.units.size(),"protocol":"Same production rules and sanitized observations. Fixed V43.15 Prussian Hard opponent, French V43.15 versus new Hard only. Full uses untouched 95-unit campaign start. Pincer is a synthetic 29-unit deployment with all arrivals T1, original map, three original objectives and original individual strengths. It is not the user's exact playthrough or a chronological 95-unit battle.","phases":[],"actions":[],"complete":false}
 check(e.validate(e.state),"initial state valid")
 var started=Time.get_ticks_msec()
 while not e.state.finished and int(e.state.turn)<=last_turn and failures==0:
  var side=int(e.state.side);var turn=int(e.state.turn);var counts={};var ended=false;var event_start=e.state.events.size();var clock=Time.get_ticks_msec()
  for step in range(500):
   var view=e.observation(side);var stamp=Time.get_ticks_msec();var action=french.choose(view) if side==0 else prussian.choose(view)
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
