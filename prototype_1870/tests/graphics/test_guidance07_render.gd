extends SceneTree
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func draw_frame(board):
	board.queue_redraw()
	for k in range(3):await process_frame;await RenderingServer.frame_post_draw
	return root.get_texture().get_image()
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1000,550)
	var board=load("res://tests/graphics/guidance_board.gd").new();root.add_child(board);board.size=root.size
	check(DisplayServer.get_name()!="headless","actual renderer")
	var selected=await draw_frame(board);check(selected.save_png("user://guidance_zoom_board.png")==OK,"real zoom board saved")
	board.selected=false;board.preview=false;var ordinary=await draw_frame(board)
	for n in range(4):
		var z=[0.42,0.72,1.05,2.3][n];var p=Vector2i(110+n*240,125)
		var extent=ceili(38*z)+5;var rect=Rect2i(p-Vector2i(extent,extent),Vector2i(extent*2,extent*2))
		check(selected.get_region(rect).get_data()!=ordinary.get_region(rect).get_data(),"selection visible at zoom "+str(z))
		var red=0;var ivory=0
		for x in range(rect.position.x,rect.end.x):
			for y in range(rect.position.y,rect.end.y):
				var c=selected.get_pixel(x,y)
				if c.r>.9 and c.g<.45 and c.b<.45:red+=1
				if c.r>.95 and c.g>.88 and c.b>.7:ivory+=1
		check(red>0 and ivory>0,"red tactical border and ivory selection coexist "+str(z))
		var goal=Vector2i(p.x+45,380)
		check(selected.get_pixelv(goal).r>.95 and selected.get_pixelv(goal).g>.8,"chosen destination has gold core "+str(z))
		check(selected.get_pixel(p.x,280).is_equal_approx(Color("fff2ce")),"ordinary reachable dot retains ivory core "+str(z))
		check(selected.get_region(Rect2i(p.x-65,320,130,110)).get_data()!=ordinary.get_region(Rect2i(p.x-65,320,130,110)).get_data(),"prepared route distinct from ordinary reach "+str(z))
	board.queue_free();await process_frame;print("GUIDANCE RENDER 07 ",checks-failures,"/",checks);quit(1 if failures else 0)
