extends SceneTree
var game
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func width(label):
	return label.get_theme_font("font").get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,label.get_theme_font_size("font_size")).x
func tap(area):
	var event=InputEventScreenTouch.new();event.index=0;event.position=area.get_global_rect().get_center();event.pressed=true
	Input.parse_input_event(event);await process_frame
	event=InputEventScreenTouch.new();event.index=0;event.position=area.get_global_rect().get_center();event.pressed=false
	Input.parse_input_event(event);await process_frame
func _initialize():call_deferred("run")
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1280,720)
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop()
	game.new_game(0);game.ai_enabled=false;game.music_player.stop()
	var e=game.engine
	for dimensions in [Vector2i(1280,606),Vector2i(1280,720),Vector2i(1520,720)]:
		root.size=dimensions;await process_frame;await process_frame
		for human in [0,1]:
			e.state.human_side=human
			for side in [0,1]:
				e.state.side=side
				for turn in range(1,21):
					e.state.turn=turn;e.state.finished=false;game.refresh()
					check(width(game.turn_label)<=game.turn_label.size.x,"camp caption fits")
					check(width(game.score_label)<=game.score_label.size.x,"time/turn fit "+str(turn))
					check(game.turn_label.position.x+game.turn_label.size.x<=game.hud_details.clock_panel.position.x-12,"camp and clock do not overlap")
		game.engine.state.finished=true;game.refresh()
		check(width(game.score_label)<=game.score_label.size.x,"18:00 and final turn fit")
		check(game.score_label.get_theme_font_size("font_size")==24,"clock increased from 20 to 24")
		var rects=[game.hud_details.clock_panel.get_global_rect()]
		for child in game.header.get_children():
			if child is Label and child.text==game.t("subtitle"):
				check(width(child)<=child.size.x,"full historic title fits")
				check(not child.get_global_rect().intersects(game.hud_details.clock_panel.get_global_rect()),"title and centred frame do not overlap")
		for b in game.header_buttons:
			check(b.get_theme_font_size("font_size")==22,"command font increased from 17 to 22")
			check(is_equal_approx(game.hud_details.clock_panel.get_global_rect().get_center().y,b.get_global_rect().get_center().y),"clock vertically centred on "+b.text)
			check(game.header.get_global_rect().encloses(b.get_global_rect()),"button remains in header")
			var text_width=b.get_theme_font("font").get_string_size(b.text,HORIZONTAL_ALIGNMENT_LEFT,-1,22).x
			check(text_width+18+6+b.get_theme_stylebox("normal").get_minimum_size().x<=b.size.x,"complete text and icon fit "+b.text)
			for rect in rects:check(not rect.intersects(b.get_global_rect()),"buttons/clock do not overlap")
			rects.append(b.get_global_rect())
		check(game.map.size.y==dimensions.y-272 and game.header.size.y==92 and game.footer.size.y==180,"no map area or banner height change")
	root.size=Vector2i(1280,720);await process_frame
	e.state.human_side=0;e.state.side=0;e.state.turn=12;e.state.finished=false;game.refresh();await process_frame
	for b in game.header_buttons:
		var before=JSON.stringify(e.state);await tap(b)
		check(is_instance_valid(game.modal),"real viewport touch opens "+b.text)
		check(JSON.stringify(e.state)==before,"header command leaves game state intact")
		game.close_modal();await process_frame
	var args=OS.get_cmdline_user_args()
	if args.size()>0 and DisplayServer.get_name()!="headless":
		await process_frame;await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(args[0])==OK,"actual enlarged header screenshot")
	game.playing=false;game.queue_free();await process_frame;print("HEADER EXPERIMENT 09 ",checks-failures,"/",checks);quit(1 if failures else 0)
