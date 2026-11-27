extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json")
 var e=Rules.new(JSON.parse_string(raw));e.new_game(0,"hard");e.state.seed=1870431501
 var store=Store.new("user://save_v43.json",raw.sha256_text());check(store.save_game(e),"valid existing save created in isolated user directory")
 var original=FileAccess.get_file_as_string(store.path);var snapshot=e.state.duplicate(true)
 check(not ResourceLoader.has_cached("res://intro_bd/assets/scene_1.png"),"intro artwork absent before application startup")
 var g=load("res://main.tscn").instantiate();root.add_child(g);g.ai_enabled=false;g.sound_enabled=false;g.music_player.stop();await process_frame
 check(g.has_save and g.engine.state==snapshot,"actual app startup reads existing save")
 check(g.modal_box.get_node_or_null("Introduction1870")==null,"saved startup opens menu without intro")
 check(not ResourceLoader.has_cached("res://intro_bd/assets/scene_1.png"),"saved startup does not load BD pictures")
 var resume_button
 for b in g.modal_box.find_children("*","Button",true,false):
  if b.text==g.t("continue"):resume_button=b
 check(resume_button!=null,"Continue button remains available")
 if resume_button!=null:resume_button.pressed.emit()
 await process_frame
 check(g.playing and not is_instance_valid(g.modal) and g.engine.state==snapshot,"Continue enters the same battle directly")
 check(FileAccess.get_file_as_string(store.path)==original,"original save remains byte-identical")
 check(not ResourceLoader.has_cached("res://intro_bd/assets/scene_1.png"),"continuing never loads the six intro images")
 g.playing=false;g.queue_free();await process_frame;print("DIRECT RESUME ",checks-failures,"/",checks);quit(1 if failures else 0)
