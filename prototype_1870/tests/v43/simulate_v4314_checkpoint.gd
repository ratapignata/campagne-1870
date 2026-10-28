extends "res://tests/v43/simulate_v4313_modes.gd"
const Prior=preload("res://tests/v43/reference_ai_v4313.gd")
func _initialize():
 var args=OS.get_cmdline_user_args();var mode=args[0];var out=args[1]
 profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));var s=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/v4313_t11_simulation.json"));var e=Rules.new(p,s);e.normalize();e.refresh_intel()
 var enemy=Prior.new() if mode=="reference" else bot();enemy.profiles=profiles;french_bot=bot();var w=e.index(Vector2i(13,10));var start=Time.get_ticks_msec()
 var report={"mode":mode,"protocol":"Identical checkpoint from fully autonomous V43.13 simulation, end T10. Two full turns T11-T12 with same active French policy. Not the human T20 export, not a full battle.","phases":[],"actions":[],"complete":false}
 check(e.validate(e.state),"checkpoint valid")
 while not e.state.finished and int(e.state.turn)<=12 and failures==0:
  var side=int(e.state.side);var turn=int(e.state.turn);var counts={};var elapsed=Time.get_ticks_msec();var ended=false
  var old_shots=e.state.events.size()
  for k in range(500):
   var then=Time.get_ticks_msec();var decision=defend_woerth(e,w) if side==0 else enemy.choose(e.observation(side));var ms=Time.get_ticks_msec()-then
   check(dispatch(e,decision),"legal command "+JSON.stringify(decision));check(e.validate(e.state),"valid state after command")
   counts[decision.kind]=int(counts.get(decision.kind,0))+1
   report.actions.append({"turn":turn,"side":side,"decision":decision,"decision_ms":ms})
   if k%25==0:print("PROGRESS ",mode," T",turn," side",side," decisions ",k+1)
   if failures or decision.kind=="end":ended=decision.kind=="end";break
  check(ended,"phase completed below cap")
  var guns=0
  for j in range(old_shots,e.state.events.size()):
   var event=e.state.events[j]
   if int(event.side)==side and event.kind=="fire" and event.get("cannon",false):guns+=1
  report.phases.append({"turn":turn,"side":side,"counts":counts,"cannon_shots":guns,"goals":e.state.objective_owners.duplicate(),"losses":[e.losses(0),e.losses(1)],"prisoners":[e.prisoners(0),e.prisoners(1)],"elapsed_ms":Time.get_ticks_msec()-elapsed})
  report.checks=checks;report.failures=failures;report.elapsed_ms=Time.get_ticks_msec()-start;save_report(out,report,e);print("DONE ",JSON.stringify(report.phases[-1]))
 report.complete=failures==0 and (e.state.turn>12 or e.state.finished);report.checks=checks;report.failures=failures;report.elapsed_ms=Time.get_ticks_msec()-start;save_report(out,report,e)
 print("CHECKPOINT ",mode," ",checks-failures,"/",checks);quit(1 if failures else 0)
