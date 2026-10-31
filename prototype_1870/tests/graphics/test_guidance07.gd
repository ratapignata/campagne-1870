extends SceneTree
var game
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func tap(area: Control):
	var event=InputEventScreenTouch.new();event.index=0;event.position=area.get_global_rect().get_center();event.pressed=true
	root.push_input(event,true);await process_frame
	event=InputEventScreenTouch.new();event.index=0;event.position=area.get_global_rect().get_center();event.pressed=false
	root.push_input(event,true);await process_frame
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1280,720)
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop()
	game.new_game(0);game.ai_enabled=false;game.music_player.stop()
	var e=game.engine;var n=e.unit_index("fr_9");var u=e.state.units[n];game.selected=n;game.clear_preview();game.refresh()
	var hud=game.hud_details
	for dimensions in [Vector2i(1280,606),Vector2i(1280,720),Vector2i(1520,720)]:
		root.size=dimensions;await process_frame;await process_frame;game.refresh()
		var rects=[]
		for topic in hud.help_targets:
			var area=hud.help_targets[topic]
			check(area.visible and area.mouse_filter==Control.MOUSE_FILTER_STOP,"known own icon help available "+topic)
			check(game.unit_card.get_global_rect().encloses(area.get_global_rect()),"hit area stays in unit card "+topic)
			for other in rects:check(not other.intersects(area.get_global_rect()),"help areas do not overlap")
			rects.append(area.get_global_rect())
			var before=JSON.stringify(e.state);var disk=FileAccess.get_file_as_string(game.saver.path)
			await tap(area)
			check(is_instance_valid(game.modal),"real viewport touch opens help "+topic)
			if is_instance_valid(game.modal):
				var labels=game.modal_box.find_children("*","RichTextLabel",true,false)
				check(labels.size()==1 and not labels[0].text.is_empty(),"help has readable content "+topic)
				check(game.modal_box.get_global_rect().end.y<=dimensions.y,"help fits viewport")
				var args=OS.get_cmdline_user_args()
				if args.size()>0 and DisplayServer.get_name()!="headless" and dimensions==Vector2i(1280,720) and topic in ["ammo","command"]:
					await process_frame;await RenderingServer.frame_post_draw
					check(root.get_texture().get_image().save_png(args[0]+"/aide_"+topic+".png")==OK,"real help screenshot")
			check(JSON.stringify(e.state)==before and FileAccess.get_file_as_string(game.saver.path)==disk,"help neither orders action nor rewrites save")
			game.close_modal();await process_frame
		check(game.map.size.y==dimensions.y-272 and game.footer.size.y==180,"no map area lost")
	# Disabled actions explain their reason through the existing callback, never execute.
	u.ap=0;game.refresh();await process_frame
	var b=game.actions.entrench;var before=JSON.stringify(e.state)
	check(b.visible and b.disabled,"entrench is visible but disabled at zero AP")
	var expected=game.disabled_reason(b);await tap(b)
	check(game.context_detail.text==expected,"actual tap on disabled action displays existing reason")
	check(JSON.stringify(e.state)==before,"disabled action never executes")
	check(b.get_theme_stylebox("disabled").get_minimum_size().x==b.get_theme_stylebox("normal").get_minimum_size().x,"disabled appearance preserves button content width")
	# Suppress unknown enemy topics; invoking them must not disclose anything.
	game.unit_state.text=game.t("fog_no_state");game.ammo_label.text="";game.unit_reaction.text=game.t("fog_no_ap_info")
	game.support_label.text="";game.supply_label.text="";game.encircled_label.text="";hud.update_details()
	for topic in hud.help_targets:
		check(not hud.help_targets[topic].visible,"unknown enemy has no help cue "+topic)
		hud.show_status_help(topic);check(not is_instance_valid(game.modal),"unknown topic cannot open privileged detail "+topic)
	game.playing=false;game.queue_free();await process_frame
	print("GUIDANCE EXPERIMENT 07 ",checks-failures,"/",checks);quit(1 if failures else 0)
