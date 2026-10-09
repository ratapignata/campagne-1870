extends SceneTree
var failures=0
var checks=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: "+label)
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720)
 var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_enabled=false;game.music_player.stop()
 await process_frame
 game.scenario_choice="three";game.show_camp_choice();await process_frame
 var buttons=game.modal_box.find_children("*","Button",true,false)
 var valid=true
 for b in buttons:
  valid=valid and game.modal_box.get_global_rect().encloses(b.get_global_rect())
  for other in buttons:
   if b!=other:valid=valid and not b.get_global_rect().intersects(other.get_global_rect())
 check(valid,"scenario menu buttons contained without overlap")
 for side in [0,1]:
  game.scenario_choice="three";game.new_game(side);game.ai_enabled=false
  check(game.engine.state.human_side==side and game.engine.objective_definitions().size()==3,"trial starts camp "+str(side))
  check(game.saver.path=="user://save_three_v0820.json","separate trial save")
  game.engine.state.units[0].ap=11;game.persist()
  var stored=game.saved_scenario("three");check(not stored.is_empty(),"trial save visible")
 game.scenario_choice="classic";game.new_game(0);game.ai_enabled=false
 check(game.engine.objective_definitions().size()==1 and game.saver.path=="user://save_classic_v0820.json","classic still playable")
 game.scenario_choice="three";game.resume_scenario();game.ai_enabled=false
 check(game.engine.state.units[0].ap==11 and game.engine.state.human_side==1,"trial restored after classic")
 check(game.engine.validate(game.engine.state),"resumed state valid")
 game.playing=false;game.queue_free();await process_frame
 var reopened=load("res://main.tscn").instantiate();root.add_child(reopened);reopened.ai_enabled=false;reopened.music_player.stop()
 await process_frame
 check(reopened.has_save and reopened.engine.state.human_side==1 and reopened.engine.state.units[0].ap==11,"application restart resumes chosen scenario")
 reopened.playing=false;reopened.queue_free();await process_frame
 print("TRIAL UI ",checks-failures,"/",checks," passed; headless")
 quit(1 if failures else 0)
