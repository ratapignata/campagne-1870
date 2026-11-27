extends "res://tests/v43/test_v4317_ai.gd"
const Old70=preload("res://tests/reference_v70/tactical_ai.gd")
const FirePlan=preload("res://war_engine/ai/french_fire_plan.gd")
func masked():
 var e=small(["art_fr_Pellé0","fr_7","fr_9","fr_10","fr_14","pru_36","qg_fr_Pellé"],[[10,5],[10,7],[11,5],[13,10],[18,6],[10,10],[10,2]])
 e.state.units[0].deployed=true;e.state.units[1].done=false
 return e
func phase(e,brain) -> int:
 var start=e.state.events.size()
 for k in range(40):
  var view=observed(e);var before=view.duplicate(true);var action=brain.choose(view)
  check(view==before and dispatch(e,action) and e.validate(e.state),"real native phase order and immutable observation")
  if action.kind=="end":break
 var result=0
 for k in range(start,e.state.events.size()):
  if e.state.events[k].kind=="fire" and e.state.events[k].cannon and e.state.events[k].side==0:result+=1
 return result
func _initialize():
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=masked();check(e.fire_status(0,5)=="blocked_friendly","real infantry screen initially masks deployed gun")
 var brain=bot();var view=observed(e);var untouched=view.duplicate(true);var action=brain.choose(view)
 check(action.kind=="move" and action.unit=="fr_7" and dispatch(e,action),"one legal lateral infantry move opens the gun lane")
 check(e.state.units[1].ap==12 and view==untouched,"infantry really pays one PA and planning preserves its input")
 action=brain.choose(observed(e))
 check(action.kind=="fire" and action.unit=="art_fr_Pellé0" and dispatch(e,action) and e.state.units[0].ap==4,"newly freed cannon fires now and pays three PA")
 check(e.state.units[2].cell==[11,5] and e.state.units[3].cell==[13,10] and e.state.units[4].cell==[18,6],"all objective garrisons remain in place")
 var old=Old70.new();old.profiles=profiles
 var baseline=phase(masked(),old);var improved=phase(masked(),bot())
 print("MASKED BATTERY V70=",baseline," V70.1=",improved)
 check(improved>baseline,"same masked-lane position produces more real cannon shots than V70")
 var double=small(["art_fr_Pellé0","fr_7","fr_8","fr_9","fr_10","fr_14","pru_36","qg_fr_Pellé"],[[10,5],[10,7],[10,8],[11,5],[13,10],[18,6],[10,11],[10,2]])
 double.state.units[0].deployed=true;double.state.units[1].done=false;double.state.units[2].done=false
 var old_double=Rules.new(double.pack,double.state.duplicate(true));old_double.normalize()
 old=Old70.new();old.profiles=profiles
 var before_double=phase(old_double,old);var after_double=phase(double,bot())
 print("DOUBLE SCREEN V70=",before_double," V70.1=",after_double)
 check(after_double>before_double,"two native infantry moves can open a genuinely usable gun lane in the same phase")
 e=small(["art_fr_Pellé0","fr_7","pru_36"],[[10,5],[11,6],[10,13]])
 e.state.units[0].turn_ap_limit=12;e.state.units[0].ap=12
 check(not e.state.units[0].command_ok and e.state.units[0].supply_ok,"setup fixture has native three-PA command penalty")
 brain=bot();action=brain.choose(observed(e));print("RESERVED SETUP ",JSON.stringify(action))
 check(action.kind=="move" and action.unit=="art_fr_Pellé0" and dispatch(e,action) and e.state.units[0].ap>=4,"relocation reserves the actual deployment PA")
 action=brain.choose(observed(e));check(action.kind=="deploy" and dispatch(e,action),"battery deploys at its reached firing position this turn")
 check(e.fire_status(0,2)!="ok","no free shot after spending movement and deployment budget")
 e.end_side();e.end_side();action=brain.choose(observed(e))
 check(action.kind=="fire" and action.unit=="art_fr_Pellé0" and dispatch(e,action),"command-limited gun really fires on the following turn")
 e=small(["art_fr_Pellé0","fr_7","pru_36","qg_fr_Pellé"],[[11,3],[11,5],[11,8],[10,2]])
 e.state.units[0].deployed=true;e.state.units[1].done=false
 brain=bot();brain.choose(observed(e));var plan=load("res://war_engine/ai/planning_engine.gd").new(observed(e).pack,observed(e).state)
 check(FirePlan.clear_lane(plan,brain.defence).is_empty(),"an objective garrison is never stripped to clear a cannon")
 e=masked();e.state.units[1].ap=2
 brain=bot();brain.choose(observed(e));plan=load("res://war_engine/ai/planning_engine.gd").new(observed(e).pack,observed(e).state)
 check(FirePlan.clear_lane(plan,brain.defence).is_empty(),"half-PA infantry cannot make a one-PA clearing move")
 e=masked();e.state.units[1].entrenched=true
 brain=bot();brain.choose(observed(e));plan=load("res://war_engine/ai/planning_engine.gd").new(observed(e).pack,observed(e).state)
 check(FirePlan.clear_lane(plan,brain.defence).is_empty(),"entrenched infantry is not pulled out of its prepared position for a cannon")
 view=e.observation(0,[]);action=bot().choose(view)
 check(action.kind!="fire","a hidden enemy cannot produce a firing order")
 print("V70.1 ARTILLERY ",checks-failures,"/",checks);quit(1 if failures else 0)
