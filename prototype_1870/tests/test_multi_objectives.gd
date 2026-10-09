extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
const Legacy=preload("res://war_engine/ai/legacy_ai.gd")
var failures=0
var checks=0
func check(ok: bool,label: String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+label)
func make_pack():
 var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json"))
 p.map.tiles.fill("plain");p.map.river_edges=[];p.map.elevations.fill(0);p.rules.fog.enabled=false;p.rules.support.enabled=false
 p.objectives=[{"id":"a","cell":[4,4],"points":3,"initial_owner":-1},{"id":"b","cell":[12,4],"points":2,"initial_owner":-1},{"id":"c","cell":[20,4],"points":1,"initial_owner":-1}]
 for i in range(p.units.size()):p.units[i].cell=[i*2,15]
 return p
func _initialize():
 var p=make_pack();var e=Rules.new(p)
 check(e.validate(e.state),"initial multi state")
 check(e.objective_definitions().size()==3 and e.objective_value_total()==6,"3 objective values")
 e.state.units[0].cell=[12,5];var target=e.objective_cell(p.objectives[1]);var path=e.path_to(0,target)
 check(not path.is_empty(),"second objective reachable")
 check(e.move(0,path)=="capture" and e.objective_owner(p.objectives[1])==0,"movement captures second objective")
 check(not e.undo(),"capture locks undo")
 check(e.state.owner==-1,"second capture leaves first owner intact")
 e.end_side();check(e.state.scores==[0,0],"no score on half turn")
 e.end_side();check(e.state.scores==[2,0],"second objective weighted full turn score")
 e.state.units[0].cell=[12,5];e.end_side();e.end_side();check(e.state.scores==[4,0],"empty objective retained")
 e.state.units[0].cell=[20,4];e.state.units[0].morale="routed"
 check(not e.capture_objective(e.objective_cell(p.objectives[2]),0),"routed unit cannot capture")
 e.state.units[0].morale="stable";check(e.capture_objective(e.objective_cell(p.objectives[2]),0),"third objective capture")
 var store=Store.new("user://multi_test.json","test-multi")
 check(store.save_game(e),"save multi objectives")
 var loaded=Rules.new(p);var loaded_ok=store.load_game(loaded)
 check(loaded_ok and loaded.validate(loaded.state) and JSON.parse_string(JSON.stringify(loaded.state))==JSON.parse_string(JSON.stringify(e.state)),"load exact multi state")
 var bad=e.state.duplicate(true);bad.objective_owners.erase("b");check(not e.validate(bad),"missing owner rejected")
 bad=e.state.duplicate(true);bad.objective_owners.c=5;check(not e.validate(bad),"invalid owner rejected")
 e.state.finished=true;var fr=e.result_for(0);var pr=e.result_for(1)
 check(is_equal_approx(fr.parts[0][0],30.0),"half objective value grants half final score")
 check(fr.winner==pr.winner and fr.level=="minor_win" and pr.level=="minor_loss","symmetric result")
 bad=e.state.duplicate(true);bad.scores=[99999,0];check(not e.validate(bad),"impossible objective score rejected")
 var old_pack=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json"));var old=Rules.new(old_pack);var old_state=old.state.duplicate(true);old_state.erase("objective_owners")
 check(old.validate(old_state),"old single-objective save accepted")
 old.state=old_state;old.normalize();check(old.objective_definitions().size()==1 and old.state.objective_owners.size()==1,"legacy owner migrated")
 var sim=Rules.new(p);sim.state.units[0].cell=[20,5]
 var goal=Legacy.new().target_goal(sim,0);check(goal==sim.objective_cell(p.objectives[2]),"AI can prioritize third objective")
 var view=sim.observation(0,[])
 check(view.state.units.all(func(u):return int(u.side)==0),"AI observation excludes unseen enemies")
 var profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json")) if FileAccess.file_exists("res://packs/1870/ai_profiles.json") else {}
 # Actual profiles are embedded in the pack when no separate file exists.
 var ai=AI.new();ai.profiles=p.get("ai_profiles",profiles)
 var action=ai.choose(view);check(not action.is_empty(),"AI multi-objective action")
 var battle=Rules.new(p);battle.state.units[0].cell=[12,5];battle.state.units[4].cell=[12,4]
 battle.state.units[4].strength=1;battle.state.units[4].casualties=int(battle.state.units[4].initial_strength)-1;battle.state.units[4].reactions=0
 battle.state.seed=123
 var assault=battle.assault(0,4)
 check(assault.status=="ok" and battle.objective_owner(p.objectives[1])==0,"assault captures secondary objective")
 var cfg=p.rules.victory;var result_engine=Rules.new(p)
 result_engine.state.owner=0;result_engine.state.objective_owners={"a":0,"b":0,"c":1};result_engine.state.scores=[15,21];result_engine.state.finished=true
 for u in result_engine.state.units:
  u.casualties=int(u.initial_strength)*(0.1 if int(u.side)==0 else 0.3);u.strength=int(u.initial_strength)-int(u.casualties)
 check(result_engine.result_for(0).level=="major_win" and result_engine.result_for(1).level=="major_loss","weighted multi major result")
 for difficulty in ["easy","medium","hard"]:
  view.state.ai_difficulty=difficulty
  check(not ai.choose(view).is_empty(),"multi AI "+difficulty)
 print("MULTI OBJECTIVES: ",checks," checks, ",failures," failures")
 quit(1 if failures else 0)
