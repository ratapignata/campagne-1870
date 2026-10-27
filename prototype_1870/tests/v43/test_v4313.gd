extends "res://tests/test_ai_compat0833.gd"
const Prior=preload("res://tests/v43/reference_ai_v4312.gd")
func gun_fixture():
 var p=data.duplicate(true);p.units=[]
 for id in ["pru_39","fr_7","pru_36","art_pr_Schmidt0","fr_18","qg_pr_Schachtmeyer"]:
  for u in data.units:
   if u.id==id:p.units.append(u.duplicate(true))
 p.rules.support.enabled=false;p.rules.fog.enabled=false
 var cells=[[13,11],[13,10],[13,12],[19,14],[22,10],[18,14]]
 for n in range(p.units.size()):p.units[n].arrival_turn=1;p.units[n].cell=cells[n]
 p.units[3].command_group="pr_Gersdorff"
 var e=Rules.new(p);e.new_game(0,"hard");e.state.side=1;e.state.turn=8
 for n in [0,2,5]:e.state.units[n].ap=0;e.state.units[n].done=true
 e.state.units[3].deployed=true;return e
func assault_fixture():
 var p=data.duplicate(true);p.units=[];p.rules.support.enabled=false;p.rules.fog.enabled=false;p.map.river_edges=[];p.map.tiles.fill("plain");p.map.elevations.fill(0)
 for id in ["pru_36","pru_37","pru_38","fr_7","fr_6"]:
  for u in data.units:
   if u.id==id:p.units.append(u.duplicate(true))
 var cells=[[13,8],[14,8],[12,8],[13,6],[11,5]]
 for n in range(p.units.size()):p.units[n].arrival_turn=1;p.units[n].cell=cells[n]
 p.units[3].initial_strength=500
 var e=Rules.new(p);e.new_game(0,"hard");e.state.side=1;e.state.turn=8;e.state.units[0].formation="column";e.state.units[0].ammo_level=2
 for n in [1,2]:e.state.units[n].ap=0;e.state.units[n].done=true
 return e
func _initialize():
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=Rules.new(data);e.new_game(0,"medium");var goal=e.objective_definitions()[1]
 check(e.objective_cell(goal)==e.index(Vector2i(13,10)) and int(goal.points)==2 and goal.name_key=="goal_historical_woerth","two-point objective at Woerth")
 check(e.objective_at(e.index(Vector2i(15,4))).is_empty(),"Elsasshausen no longer scores")
 check(e.objective_value_total()==6 and e.validate(e.state),"three objectives keep total six and valid state")
 var prior_pack=data.duplicate(true);prior_pack.objectives=prior_pack.previous_objectives;prior_pack.erase("previous_objectives")
 for finished in [false,true]:
  var legacy=Rules.new(prior_pack);legacy.new_game(0,"hard");legacy.state.turn=20 if finished else 6;legacy.state.finished=finished;legacy.state.objective_owners.elsasshausen=1;legacy.state.scores=[18,12]
  var original_result=legacy.result_for(0);var path="user://old_layout_"+str(finished)+".json";var old_slot=Store.new(path,"6a44f0421df5983355ea59792e27ed67a9e9ac89def0c295b8ebdfab2a12574b")
  check(old_slot.save_game(legacy),"old-format fixture saves")
  var original=FileAccess.get_file_as_string(path);var current=Store.new(path,FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json").sha256_text(),data.save_migrations);var restored=Rules.new(data)
  check(current.load_game(restored),"old layout loads")
  check(restored.state.objective_layout=="v4312" and restored.objective_cell(restored.objective_definitions()[1])==restored.index(Vector2i(15,4)),"old party keeps original objectives")
  check(restored.result_for(0)==original_result,"old party score unchanged")
  check(FileAccess.get_file_as_string(path)==original,"load leaves original file intact")
  check(current.save_game(restored) and current.load_game(restored) and restored.objective_cell(restored.objective_definitions()[1])==restored.index(Vector2i(15,4)),"legacy layout survives new-format save/reload")
  restored.new_game();check(restored.objective_cell(restored.objective_definitions()[1])==restored.index(Vector2i(13,10)),"new game resets to Woerth objective")
 e=gun_fixture();var old=Prior.new();old.profiles=profiles;var ai=bot();var view=e.observation(1,[1,4]);var before=view.duplicate(true);var a=old.choose(view);var b=ai.choose(view)
 print("WING GUN ",JSON.stringify(a)," -> ",JSON.stringify(b))
 check(e.fire_status(3,4)=="ok" and e.fire_status(3,1)!="ok","wing gun has secondary shot but not central bridgehead")
 check(b.kind=="fire","wing battery fires rather than chase central bridgehead")
 check(view==before and dispatch(e,b) and e.validate(e.state),"wing shot legal and input intact")
 e=gun_fixture();e.state.units[3].deployed=false;ai=bot();view=e.observation(1,[1,4]);a=old.choose(view);b=ai.choose(view);print("WING DEPLOY ",JSON.stringify(a)," -> ",JSON.stringify(b))
 check(b.kind=="deploy","useful wing firing lane triggers deployment")
 check(dispatch(e,b),"deployment legal")
 var shot=ai.choose(e.observation(1,[1,4]));check(shot.kind=="fire" and dispatch(e,shot) and e.validate(e.state),"wing battery actually fires after deployment")
 e=assault_fixture();ai=bot();view=e.observation(1,[3,4]);a=old.choose(view);b=ai.choose(view);print("MOVE ASSAULT ",JSON.stringify(a)," -> ",JSON.stringify(b))
 check(b.kind=="move","infantry chooses assault approach")
 check(dispatch(e,b) and int(e.state.units[0].ap)>=e.assault_cost(0),"approach preserves assault AP")
 var restored_ai=bot();restored_ai.relocation=JSON.parse_string(JSON.stringify(ai.relocation));var attack=restored_ai.choose(e.observation(1,[3,4]));print("FOLLOW ",JSON.stringify(attack));check(attack.kind=="assault" and dispatch(e,attack) and e.validate(e.state),"approach followed by real legal assault")
 var stale=bot();stale.relocation=ai.relocation.duplicate(true);check(stale.choose(e.observation(1,[3,4])).kind!="assault","spent AP invalidates old approach plan")
 var corrupt_payload=JSON.stringify({"state":"invalid","previous":{}});var corrupt_path="user://invalid_legacy_objective_state.json";var file=FileAccess.open(corrupt_path,FileAccess.WRITE);var corrupt=JSON.stringify({"schema":1,"pack_hash":"6a44f0421df5983355ea59792e27ed67a9e9ac89def0c295b8ebdfab2a12574b","payload":corrupt_payload,"checksum":corrupt_payload.sha256_text()});file.store_string(corrupt);file.close()
 var corrupt_slot=Store.new(corrupt_path,FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json").sha256_text(),data.save_migrations)
 check(corrupt_slot.read_slot(corrupt_path).is_empty(),"malformed legacy state rejected before objective migration")
 check(not corrupt_slot.load_game(Rules.new(data)),"malformed legacy slot cannot load")
 check(FileAccess.get_file_as_string(corrupt_path)==corrupt,"invalid slot not overwritten on load")
 print("V43.13 ",checks-failures,"/",checks);quit(1 if failures else 0)
