extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1600,1200)
 var board=load("res://tests/v43/animation_board.gd").new();root.add_child(board);board.size=Vector2(1600,1200);board.set_process(false);board.cannon_mode=false
 var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"))
 for key in p.terrains:board.terrain_colors.append({"name":key,"color":Color(p.terrains[key].color)})
 check(DisplayServer.get_name()!="headless","actual graphical renderer")
 check(board.projectile_ink(true)==Color("252a30"),"cannon colour restored")
 check(board.projectile_ink(false)==Color("d8ddd9"),"infantry tracer colour")
 var hashes=[]
 for phase in board.phases:
  board.phase=phase;board.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
  var picture=root.get_texture().get_image();hashes.append(picture.get_data().hex_encode().sha256_text())
  check(picture.save_png("user://rifle_phase_%02d.png"%int(phase*100))==OK,"rifle phase screenshot")
  check(picture.get_width()==1600 and picture.get_height()==1200,"rifle render dimensions")
 check(hashes[0]!=hashes[2] and hashes[2]!=hashes[4],"distinct firing, flight and impact frames")
 board.queue_free();await process_frame;print("RIFLE RENDER ",checks-failures,"/",checks);quit(1 if failures else 0)
