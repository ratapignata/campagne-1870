extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var raw=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"))
 raw.map.tiles.fill("plain");raw.map.elevations.fill(0);raw.map.river_edges=[];raw.map.road_edges=[]
 for side in [0,1]:
  var e=Rules.new(raw);var own=-1;var hidden=-1
  for n in range(e.state.units.size()):
   var u=e.state.units[n]
   if not e.cavalry(n) and not e.artillery(n) and not e.headquarters(n):
    if u.side==side:own=n
    else:hidden=n
   u.strength=0;u.casualties=u.initial_strength;u.pending=false;u.done=true;u.ap=0
  for n in [own,hidden]:
   var u=e.state.units[n];u.strength=u.initial_strength;u.casualties=0;u.ap=16;u.done=false
  e.state.units[own].cell=[2,2];e.state.units[hidden].cell=[27,17];e.state.side=side;e.refresh_support();e.refresh_intel()
  var other=Rules.new(e.pack,e.state)
  other.state.units[hidden].cell=[26,18];other.state.units[hidden].strength=117;other.state.units[hidden].casualties=other.state.units[hidden].initial_strength-117;other.state.seed=888;other.state.moves=999;other.refresh_support();other.refresh_intel()
  for difficulty in ["easy","medium","hard"]:
   e.state.ai_difficulty=difficulty;other.state.ai_difficulty=difficulty
   var a=e.observation(side);var b=other.observation(side);check(a==b,"V35 same hidden worlds "+str(side)+difficulty)
   var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
   var before=a.duplicate(true);check(ai.choose(a)==ai.choose(b),"V35 same hidden decisions "+str(side)+difficulty);check(a==before,"V35 input unmodified "+str(side)+difficulty)
 print("V35 HIDDEN WORLDS ",checks-failures,"/",checks);quit(1 if failures else 0)
