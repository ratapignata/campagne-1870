extends "res://tests/v43/test_v4317_ai.gd"
const Batteries70=preload("res://war_engine/ai/french_batteries.gd")
const Previous=preload("res://war_engine/ai/v4317_ai.gd")
func _initialize():
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=small(["art_fr_Pellé0","pru_36","qg_fr_Pellé"],[[10,5],[10,8],[9,2]])
 e.state.units[0].deployed=true
 var brain=bot();var view=observed(e);var original=view.duplicate(true);var a=brain.choose(view)
 check(a.kind=="fire" and a.unit=="art_fr_Pellé0" and dispatch(e,a),"unthreatened three-hex battery executes a legal shot before an unnecessary fallback")
 check(e.state.units[0].ap==4 and view==original,"no free AP, no mutation of the sanitized observation")
 a=brain.choose(observed(e))
 check(not (a.get("unit","")=="art_fr_Pellé0" and a.kind in ["limber","move"]),"productive deployed battery retains its lane after firing")
 check(not brain.defence.battery_exposed(load("res://war_engine/ai/planning_engine.gd").new(observed(e).pack,observed(e).state),0,e.unit_cell(e.state.units[0])),"infantry three hexes away does not force a premature retreat")
 e=small(["art_fr_Pellé0","fr_7","pru_36","qg_fr_Pellé"],[[10,5],[11,6],[10,7],[9,2]])
 brain=bot();brain.choose(observed(e));var plan=load("res://war_engine/ai/planning_engine.gd").new(observed(e).pack,observed(e).state)
 check(Batteries70.screen(plan,brain.defence,0,e.unit_cell(e.state.units[0]),e.unit_cell(e.state.units[2])),"real infantry between cannon and attacker supplies a planning screen")
 e=small(["art_fr_Pellé0","pru_54","qg_fr_Pellé"],[[10,5],[10,8],[9,2]])
 brain=bot();brain.choose(observed(e));plan=load("res://war_engine/ai/planning_engine.gd").new(observed(e).pack,observed(e).state)
 check(Batteries70.urgent(plan,brain.defence,0,e.unit_cell(e.state.units[0])),"near cavalry without infantry cover still requires a retreat")
 e=small(["art_fr_Pellé0","fr_8","fr_7","fr_9","fr_10","pru_36","qg_fr_Pellé"],[[12,6],[12,4],[11,5],[13,10],[18,6],[15,6],[9,2]])
 e.state.units[1].done=false
 brain=bot();view=observed(e);a=brain.choose(view)
 check(brain.defence.battery_screens.size()==1 and brain.defence.battery_screens.has(1),"one spare infantry formation covers an exposed local battery")
 check(not brain.defence.battery_screens.has(2) and not brain.defence.battery_screens.has(3) and not brain.defence.battery_screens.has(4),"first defenders of all objectives retain their missions")
 check(dispatch(e,a) and e.validate(e.state),"screen or gun order is legal in the real engine")
 for step in range(12):
  a=brain.choose(observed(e))
  if a.kind=="end":break
  check(dispatch(e,a) and e.validate(e.state),"infantry protection develops through real legal actions")
 var infantry_cell=e.unit_cell(e.state.units[1]);var gun_cell=e.unit_cell(e.state.units[0]);var enemy_cell=e.unit_cell(e.state.units[5])
 check(e.distance(infantry_cell,gun_cell)<=2 and e.distance(infantry_cell,enemy_cell)<e.distance(gun_cell,enemy_cell),"the assigned infantry actually reaches and retains a position ahead of its battery")
 for style in [0,1]:
  e=small(["art_fr_Pellé0","fr_7","pru_36","qg_fr_Pellé"],[[10,5],[11,5],[10,10],[9,2]])
  e.state.units[0].deployed=true;e.state.units[1].done=false;e.state.ai_style=style
  var current=bot();var previous=Previous.new();previous.profiles=profiles
  for step in range(8):
   view=observed(e);view.state.ai_difficulty="medium";var former=view.duplicate(true);former.state.ai_difficulty="hard"
   a=current.choose(view);var expected=previous.choose(former)
   check(a==expected and current.relocation==previous.relocation,"V70 Normal reproduces complete V43.17 Hard decision and relocation")
   check(dispatch(e,a) and e.validate(e.state),"normal reference order executes without changing the combat rules")
   if a.kind=="end":break
 check(data.weapons.chassepot.range==4 and data.weapons.chassepot.reaction_range==3 and data.weapons.french_rifled.ap==12 and data.weapons.krupp.ap==8,"weapon ranges, reactions and gun costs preserved")
 print("V70 ARTILLERY/NORMAL ",checks-failures,"/",checks);quit(1 if failures else 0)
