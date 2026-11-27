extends "res://tests/v43/simulate_v70.gd"
const Reference70=preload("res://tests/reference_v70/tactical_ai.gd")
func _initialize():
 var a=OS.get_cmdline_user_args();var policy=a[0];var checkpoint=a[1];var out=a[2];var last=int(a[3])
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=Rules.new(data)
 if checkpoint=="new":e.new_game(1,"hard");e.state.seed=669381;e.state.ai_style=0
 else:e.state=JSON.parse_string(FileAccess.get_file_as_string(checkpoint));e.normalize()
 var start_turn=int(e.state.turn);var first_event=e.state.events.size();var initial=e.state.duplicate(true)
 check(e.validate(e.state) and e.state.side==0,"valid common starting state")
 var french=Reference70.new() if policy=="v70" else bot();french.profiles=profiles;var prussian=Prior.new();prussian.profiles=profiles
 var result={"policy":policy,"checkpoint":checkpoint.get_file(),"start_turn":start_turn,"last_turn":last,"seed":e.state.seed,"style":e.state.ai_style,"units":e.state.units.size(),"protocol":"Identical verified V70 replay checkpoint, native95-unit scenario and current rules. Fixed active V43.17 Prussian Hard opponent. No exact human replay and no complete20-turn battle claim.","phases":[],"actions":[],"complete":false}
 var clock=Time.get_ticks_msec()
 while not e.state.finished and int(e.state.turn)<=last and failures==0:
  var side=int(e.state.side);var turn=int(e.state.turn);var from=e.state.events.size();var orders={};var ended=false
  for step in range(500):
   var view=e.observation(side);view.state.ai_difficulty="hard";var copy=view.duplicate(true)
   var action=french.choose(view) if side==0 else prussian.choose(view)
   check(view==copy,"observation immutable")
   result.actions.append({"turn":turn,"side":side,"action":action})
   check(dispatch(e,action) and e.validate(e.state),"real legal order "+JSON.stringify(action))
   orders[action.kind]=int(orders.get(action.kind,0))+1
   if action.kind=="end" or failures>0:ended=action.kind=="end";break
  check(ended,"phase finishes before action cap")
  var cannon=0;var damage=0
  for k in range(from,e.state.events.size()):
   var event=e.state.events[k]
   if int(event.side)==side and event.kind=="fire" and event.cannon:cannon+=1;damage+=int(event.loss)
  result.phases.append({"turn":turn,"side":side,"orders":orders,"cannon":cannon,"cannon_losses":damage,"french":report_state(e),"losses":[e.losses(0),e.losses(1)],"prisoners":[e.prisoners(0),e.prisoners(1)],"objectives":e.state.objective_owners.duplicate()})
  result.checks=checks;result.failures=failures
  var file=FileAccess.open(out,FileAccess.WRITE);file.store_string(JSON.stringify(result));file.close()
  print("WINDOW ",policy," ",JSON.stringify(result.phases[-1]))
 result.complete=failures==0 and (e.state.finished or int(e.state.turn)>last);result.finished=e.state.finished;result.elapsed_ms=Time.get_ticks_msec()-clock;result.checks=checks;result.failures=failures;result.history=e.state.battle_history
 result.starting_state_hash=JSON.stringify(initial).sha256_text()
 var file=FileAccess.open(out,FileAccess.WRITE);file.store_string(JSON.stringify(result,"\t"));file.close()
 file=FileAccess.open(out+".state.json",FileAccess.WRITE);file.store_string(JSON.stringify(e.state));file.close()
 print("V70.1 WINDOW ",checks-failures,"/",checks);quit(1 if failures else 0)
