extends SceneTree
var checks=0
var failures=0
func check(ok:bool,what:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",what)
func _initialize():call_deferred("run")
func run():
 root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1600,1200)
 var board=load("res://tests/v43/animation_board.gd").new();root.add_child(board);board.size=Vector2(1600,1200);board.set_process(false)
 var pack=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"))
 for key in pack.terrains:board.terrain_colors.append({"name":key,"color":Color(pack.terrains[key].color)})
 check(board.projectile_ink(true)==Color("252a30"),"cannon projectile anthracite")
 check(board.projectile_ink(false)==Color(1.0,0.81,0.40,0.9),"infantry projectile unchanged")
 check(DisplayServer.get_name()!="headless","actual X11 software renderer, not dummy renderer")
 for phase in board.phases:
  board.phase=phase;board.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
  var image=root.get_texture().get_image();check(image.get_width()==1600 and image.get_height()==1200,"actual screenshot dimensions")
  check(image.save_png("user://artillery_phase_%02d.png"%int(phase*100))==OK,"real animation screenshot saved")
  if is_equal_approx(phase,0.35):
   for sample in board.samples:
    var p=sample.center.round();var color=image.get_pixel(int(p.x),int(p.y));var expected=board.projectile_ink(true)
    check(absf(color.r-expected.r)<0.025 and absf(color.g-expected.g)<0.025 and absf(color.b-expected.b)<0.025,"rendered dark core on "+sample.terrain+" zoom "+str(sample.zoom))
 var report={"checks":checks,"failures":failures,"renderer":RenderingServer.get_video_adapter_name(),"terrains":board.terrain_colors.size(),"zooms":[0.42,0.72,1.0,2.3],"phases":board.phases,"scope":"Actual Linux X11/OpenGL software rendering, not physical Android."}
 var f=FileAccess.open("user://animation_render_report.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
 board.queue_free();await process_frame;print("V43 ANIMATION RENDER ",checks-failures,"/",checks);quit(1 if failures else 0)
