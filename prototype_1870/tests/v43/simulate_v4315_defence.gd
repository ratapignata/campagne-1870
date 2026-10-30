extends "res://tests/test_ai_compat0833.gd"
const Prior=preload("res://tests/v43/reference_ai_v4314.gd")
func save_report(path,report,e):
 var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
 f=FileAccess.open(path+".state.json",FileAccess.WRITE);f.store_string(JSON.stringify(e.state));f.close()
func _initialize():
 var args=OS.get_cmdline_user_args();var policy=args[0];var out=args[1];var seed_value=int(args[2]) if args.size()>2 else 18704315;var last_turn=int(args[3]) if args.size()>3 else 4
 profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));var e=Rules.new(data);e.new_game(1,"hard");e.state.seed=seed_value;e.state.ai_style=0
 if args.size()>4:
  e.state=JSON.parse_string(FileAccess.get_file_as_string(args[4]));e.normalize();e.refresh_intel()
 var french=Prior.new() if policy in ["reference","normal"] else bot();french.profiles=profiles;var prussian=Prior.new();prussian.profiles=profiles
 var report={"policy":policy,"seed":seed_value,"style":0,"start_turn":int(e.state.turn),"last_turn":last_turn,"protocol":"Full 95-unit scenario, chronological phases with optional save/reload at turn boundary. Actual production French decisions, no scripted Woerth garrison. Same V43.14 Hard Prussian opponent and Hard reinforcement calendar for all policies, including isolated Normal-policy control. Human side set to Prussian. No strength/AP/map changes.","phases":[],"actions":[],"complete":false};var start=Time.get_ticks_msec()
 check(e.validate(e.state),"initial scenario valid")
 while not e.state.finished and int(e.state.turn)<=last_turn and failures==0:
  var side=int(e.state.side);var turn=int(e.state.turn);var counts={};var then=Time.get_ticks_msec();var ended=false;var event_start=e.state.events.size()
  for k in range(500):
   var view=e.observation(side)
   if side==0 and policy=="normal":view.state.ai_difficulty="medium"
   var clock=Time.get_ticks_msec();var decision=french.choose(view) if side==0 else prussian.choose(view);var ms=Time.get_ticks_msec()-clock
   check(dispatch(e,decision),"legal "+JSON.stringify(decision));check(e.validate(e.state),"valid state")
   counts[decision.kind]=int(counts.get(decision.kind,0))+1;report.actions.append({"turn":turn,"side":side,"decision":decision,"decision_ms":ms})
   if k%30==0:print("PROGRESS ",policy," T",turn," side",side," action ",k+1)
   if failures or decision.kind=="end":ended=decision.kind=="end";break
  check(ended,"phase cap not reached")
  var guns=0;var covered=0;var dug=0
  for j in range(event_start,e.state.events.size()):
   var event=e.state.events[j]
   if int(event.side)==side and event.kind=="fire" and event.get("cannon",false):guns+=1
  for n in range(e.state.units.size()):
   var u=e.state.units[n]
   if not e.alive(n) or int(u.side)!=0 or e.artillery(n) or e.cavalry(n) or e.headquarters(n):continue
   if float(e.pack.terrains[e.pack.map.tiles[e.unit_cell(u)]].fire_received)<=0.65:covered+=1
   if u.entrenched:dug+=1
  report.phases.append({"turn":turn,"side":side,"counts":counts,"cannon_shots":guns,"french_covered_infantry":covered,"french_entrenched_infantry":dug,"goals":e.state.objective_owners.duplicate(),"losses":[e.losses(0),e.losses(1)],"prisoners":[e.prisoners(0),e.prisoners(1)],"elapsed_ms":Time.get_ticks_msec()-then})
  report.checks=checks;report.failures=failures;report.elapsed_ms=Time.get_ticks_msec()-start;save_report(out,report,e);print("DONE ",policy," ",JSON.stringify(report.phases[-1]))
 report.complete=failures==0 and (e.state.turn>last_turn or e.state.finished);report.checks=checks;report.failures=failures;report.elapsed_ms=Time.get_ticks_msec()-start
 save_report(out,report,e);print("DEFENCE ",policy," ",checks-failures,"/",checks);quit(1 if failures else 0)
