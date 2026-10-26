extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
const Old=preload("res://tests/v43/reference_ai_v4310.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture():
 var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));var roster=[]
 for id in ["pru_39","fr_7","pru_36","art_pr_Schmidt0","fr_18","qg_pr_Schachtmeyer"]:
  for u in p.units:
   if u.id==id:roster.append(u.duplicate(true));break
 p.units=roster;p.rules.support.enabled=false;p.rules.fog.enabled=false
 var cells=[[13,11],[13,10],[13,12],[19,14],[22,10],[18,14]]
 for n in range(p.units.size()):p.units[n].arrival_turn=1;p.units[n].cell=cells[n]
 var e=Rules.new(p);e.new_game(0,"hard");e.state.side=1;e.state.turn=12
 for n in [0,2,5]:e.state.units[n].ap=0;e.state.units[n].done=true
 e.state.units[3].deployed=true;return e
func _initialize():
 var profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"));var ai=AI.new();ai.profiles=profiles;var old=Old.new();old.profiles=profiles;var e=fixture();var view=e.observation(1,[1,4]);var before=view.duplicate(true)
 var prior=old.choose(view);var chosen=ai.choose(view);print("BRIDGE CHOICES ",JSON.stringify(prior)," -> ",JSON.stringify(chosen))
 check(not ai.bridge_targets.is_empty(),"observed bridgehead with waiting troops prioritised")
 check(view==before,"planning leaves observation intact")
 check(e.fire_status(3,1)!="ok" and e.fire_status(3,4)=="ok","fixture has blocked bridgehead and valid secondary shot")
 check(prior.kind=="fire","reference fires at secondary target")
 check(chosen.kind=="limber","battery without bridgehead LOS relocates")
 check(e.toggle_deployment(3),"limber command legal")
 var next=ai.choose(e.observation(1,[1,4]));check(next.kind=="move","relocation uses an ordinary move")
 if next.kind=="move":check(e.move(3,next.path) in ["moved","discovered","capture"] and e.validate(e.state),"relocation obeys movement rules")
 e=fixture();e.state.turn=9;ai.choose(e.observation(1,[1,4]));check(not ai.bridge_targets.is_empty(),"bridge mission already active at turn 9")
 e=fixture();e.state.turn=3;ai.choose(e.observation(1,[1,4]));check(ai.bridge_targets.is_empty(),"closed bridge creates no crossing mission")
 e=fixture();view=e.observation(1,[]);check(ai.choose(view)==old.choose(view) and ai.bridge_targets.is_empty(),"hidden defenders do not affect decisions")
 e=fixture();e.state.ai_difficulty="medium";view=e.observation(1,[1,4]);check(ai.choose(view)==old.choose(view),"Normal doctrine unchanged")
 e=fixture();e.state.side=0;view=e.observation(0,[0,2,3]);check(ai.choose(view)==old.choose(view),"French doctrine unchanged")
 print("BRIDGE BARRAGE ",checks-failures,"/",checks);quit(1 if failures else 0)
