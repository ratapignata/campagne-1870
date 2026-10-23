extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop()
 for side in [0,1]:
  game.new_game(side);game.ai_enabled=false;game.music_player.stop()
  var seen={}
  for n in range(game.engine.state.units.size()):
   var u=game.engine.state.units[n]
   if int(u.side)!=side:continue
   var kind="artillery" if game.engine.artillery(n) else "cavalry" if game.engine.cavalry(n) else "hq" if game.engine.headquarters(n) else "infantry"
   if seen.has(kind):continue
   seen[kind]=true
   if u.get("pending",false):u.pending=false;u.strength=u.initial_strength;u.ap=16;u.done=false
   game.selected=n;game.target=-1;game.refresh()
   check(game.weapon_label.text.is_empty(),"weapon line removed for all arms "+str(side)+"/"+kind)
   check(not game.unit_info.text.is_empty() and not game.unit_ap.text.is_empty(),"strength and AP remain visible")
  check(seen.has("infantry") and seen.has("hq") and seen.has("artillery") and seen.has("cavalry"),"four arms checked")
 game.playing=false;game.queue_free();await process_frame
 print("RIFLE LABEL ",checks-failures,"/",checks);quit(1 if failures else 0)
