extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
const Previous=preload("res://tests/v43/reference_ai_v439.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture():
 var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));var roster=[]
 for id in ["pru_44","fr_11","qg_pr_Schachtmeyer"]:
  for u in p.units:
   if u.id==id:roster.append(u.duplicate(true));break
 p.units=roster;p.rules.fog.enabled=false;p.map.river_edges=[];p.map.tiles.fill("water");p.map.elevations.fill(0);
 for cell in [Vector2i(17,9),Vector2i(17,8),Vector2i(18,10),Vector2i(18,11)]:p.map.tiles[cell.y*30+cell.x]="plain"
 p.map.tiles[9*30+17]="cultivated"
 p.units[1].initial_strength=353
 p.rules.support.supply_sources[1]=[[18,11]]
 for u in p.units:u.arrival_turn=1
 p.units[0].cell=[17,9];p.units[1].cell=[17,8];p.units[2].cell=[18,11]
 var e=Rules.new(p);e.new_game(0,"hard");e.state.side=1;e.state.turn=12
 var a=e.state.units[0];a.strength=1677;a.casualties=1223;a.morale="shaken";a.cohesion=50;a.ammo_level=2;a.formation="column"
 var d=e.state.units[1];d.strength=353;d.casualties=0;d.formation="line"
 e.state.units[2].ap=0;e.state.units[2].done=true;e.refresh_support(false);return e
func _initialize():
 var profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"));var old=Previous.new();old.profiles=profiles;var current=AI.new();current.profiles=profiles;var e=fixture();var view=e.observation(1,[1]);var before=view.duplicate(true)
 var old_action=old.choose(view);var action=current.choose(view);print("CHOICES ",JSON.stringify(old_action)," -> ",JSON.stringify(action))
 check(old_action.kind=="rest","previous policy chooses refill despite favourable melee")
 check(action.kind=="assault","current policy exploits favourable melee")
 check(view==before,"AI input not mutated")
 check(e.assault(0,1).status=="ok" and e.validate(e.state),"real selected assault legal and state valid")
 for difficulty in ["medium"]:
  e=fixture();e.state.ai_difficulty=difficulty;view=e.observation(1,[1]);check(old.choose(view)==current.choose(view),"Normal choice unchanged")
 e=fixture();e.state.side=0;view=e.observation(0,[0,2]);check(old.choose(view)==current.choose(view),"French hard policy unchanged")
 e=fixture();e.state.units[0].weapon="escort_dreyse";e.state.units[0].formation="line";view=e.observation(1,[1]);check(old.choose(view)==current.choose(view),"HQ policy unchanged")
 e=fixture();e.state.units[0].strength=200;e.state.units[0].casualties=2700;e.state.units[1].strength=353;e.state.units[1].casualties=0
 check(current.choose(e.observation(1,[1])).kind!="assault","unfavourable assault remains refused")
 print("ASSAULT BEFORE REST ",checks-failures,"/",checks);quit(1 if failures else 0)
