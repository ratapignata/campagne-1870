extends "res://tests/test_ai_compat0833.gd"
const Before=preload("res://tests/v43/reference_ai_v4312_initial.gd")
func _initialize():
 var e=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json")));e.state=JSON.parse_string(FileAccess.get_file_as_string("res://tests/v43/fixtures/v4312_t9_defended.json"));e.normalize()
 check(int(e.state.turn)==9 and int(e.state.side)==1 and e.validate(e.state),"real chronological T9 checkpoint valid")
 profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"));var old=Before.new();old.profiles=profiles;var ai=bot();var view=e.observation(1);var before=view.duplicate(true);var old_action=old.choose(view);var action=ai.choose(view)
 check(view==before,"priority change leaves public observation unchanged")
 var flipped=[];var old_assaults={};var new_assaults={}
 for row in old.ranked:
  if row.action.kind=="assault":old_assaults[str(row.action)]=row.score
 for row in ai.ranked:
  if row.action.kind=="assault":
   new_assaults[str(row.action)]=row.score
   if old_assaults.has(str(row.action)):
    for fire in ai.ranked:
     if fire.action.kind=="fire" and fire.action.unit==row.action.unit and fire.action.target==row.action.target and float(old_assaults[str(row.action)])<float(fire.score) and float(row.score)>float(fire.score):flipped.append(row.action)
 check(old_assaults.keys().size()==new_assaults.keys().size(),"accepted assault candidates unchanged")
 for key in old_assaults:check(new_assaults.has(key),"no new illegal/poor-ratio assault accepted")
 check(not flipped.is_empty(),"favourable assaults no longer lost behind rifle fire")
 check(action.kind=="fire" and e.artillery(e.unit_index(action.unit)),"artillery preparation remains first")
 check(dispatch(e,action) and e.validate(e.state),"selected preparation legal")
 var normal=before.duplicate(true);normal.state.ai_difficulty="medium";var normal_ai=bot();var frozen=load("res://war_engine/ai/v4311_ai.gd").new();frozen.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles_v4311.json"));var prior=normal.duplicate(true);prior.state.ai_difficulty="hard"
 check(normal_ai.choose(normal)==frozen.choose(prior),"Normal unchanged by assault priority")
 print("PRIORITY FLIPS ",JSON.stringify(flipped));print("ASSAULT COMMITMENT ",checks-failures,"/",checks);quit(1 if failures else 0)
