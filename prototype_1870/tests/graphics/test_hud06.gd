extends SceneTree
var game
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func frame():
	for k in range(3):await process_frame;await RenderingServer.frame_post_draw
	return root.get_texture().get_image()
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1280,720)
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop()
	game.new_game(0);game.ai_enabled=false;game.music_player.stop()
	var e=game.engine;var n=e.unit_index("fr_9");var u=e.state.units[n];game.selected=n;game.clear_preview()
	var hud=game.hud_details
	check(hud.mouse_filter==Control.MOUSE_FILTER_IGNORE,"decoration does not intercept touch")
	check(hud.clock_panel.mouse_filter==Control.MOUSE_FILTER_IGNORE and hud.clock_icon.mouse_filter==Control.MOUSE_FILTER_IGNORE,"clock is decorative")
	for field in [game.support_label,game.supply_label]:
		check(field.mouse_filter==Control.MOUSE_FILTER_STOP and field.get_signal_connection_list("gui_input").size()==1,"liaison help retains its input callback")
	for dims in [Vector2i(1280,606),Vector2i(1280,720),Vector2i(1520,720)]:
		root.size=dims;await process_frame;await process_frame;game.refresh()
		check(game.header.size.y==92 and game.footer.size.y==180 and game.map.size.y==dims.y-272,"map and banner heights unchanged "+str(dims))
		check(hud.clock_panel.position.x+hud.clock_panel.size.x<=game.header_buttons[0].position.x-14,"clock clear of commands")
		for index in range(game.header_buttons.size()):
			var b=game.header_buttons[index]
			check(b.size==Vector2([130,110,116][index],50),"enlarged header button dimensions retained")
			var style=b.get_theme_stylebox("normal");var text_w=b.get_theme_font("font").get_string_size(b.text,HORIZONTAL_ALIGNMENT_LEFT,-1,b.get_theme_font_size("font_size")).x
			check(b.icon!=null and b.size.x>=text_w+18+6+style.get_minimum_size().x,"icon and complete button label fit "+b.text)
		for value in [0,2,16]:
			u.ap=value;game.refresh()
			check(game.unit_ap.get_theme_font("font").get_string_size(game.unit_ap.text,HORIZONTAL_ALIGNMENT_LEFT,-1,game.unit_ap.get_theme_font_size("font_size")).x<=game.unit_ap.size.x,"complete AP including fractions fits")
		for state in ["stable","shaken","routed"]:
			u.morale=state;game.refresh()
			check(hud.cues.morale==hud.GOOD if state=="stable" else hud.cues.morale==hud.CAUTION if state=="shaken" else hud.cues.morale==hud.DANGER,"morale cue "+state)
		for links in [[true,true],[false,true],[true,false],[false,false]]:
			u.command_ok=links[0];u.supply_ok=links[1];game.refresh()
			check(hud.cues.command==(hud.GOOD if links[0] else hud.DANGER if not links[1] else hud.CAUTION),"command cue distinguishes single/double loss")
			check(hud.cues.supply==(hud.GOOD if links[1] else hud.DANGER if not links[0] else hud.CAUTION),"supply cue distinguishes single/double loss")
		var before=JSON.stringify(e.state);var width=game.ammo_label.size.x
		for k in range(3):hud.update_details()
		check(JSON.stringify(e.state)==before and game.ammo_label.size.x==width,"HUD updates are idempotent and do not mutate state")
		check(game.unit_state.position.x==44 and game.unit_reaction.position.y>=game.ammo_label.position.y+game.ammo_label.size.y,"icons keep original row spacing")
		for turn in [1,20]:
			e.state.turn=turn;e.state.finished=turn==20;game.refresh()
			var label=game.score_label
			check(label.get_theme_font("font").get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,label.get_theme_font_size("font_size")).x<=label.size.x,"clock fits including battle end")
		e.state.finished=false
	root.size=Vector2i(1280,720);await process_frame
	u.morale="shaken";u.command_ok=false;u.supply_ok=false;game.refresh()
	var args=OS.get_cmdline_user_args()
	if DisplayServer.get_name()!="headless":
		var image=await frame()
		if args.size()>0:check(image.save_png(args[0])==OK,"actual double-cut HUD screenshot written")
	# Unknown displayed information must never become a coloured tactical signal.
	game.support_label.text="";game.supply_label.text="";game.encircled_label.text="";game.unit_state.text=game.t("fog_no_state");game.ammo_label.text="";game.unit_ap.text="";hud.update_details()
	check(hud.cues.morale.a==0 and hud.cues.command.a==0 and hud.cues.supply.a==0,"unknown enemy information has no status cue")
	var before_cues=hud.cues.duplicate();var enemy=e.state.units[e.unit_index("pru_36")]
	var first: Image
	if DisplayServer.get_name()!="headless":first=(await frame()).get_region(Rect2i(game.unit_card.get_global_rect()))
	enemy.strength=1;enemy.morale="routed";enemy.command_ok=false;enemy.supply_ok=false;hud.update_details()
	check(hud.cues==before_cues,"different hidden enemy state cannot change public cues")
	if DisplayServer.get_name()!="headless":
		var second=(await frame()).get_region(Rect2i(game.unit_card.get_global_rect()))
		check(first.get_data()==second.get_data(),"hidden-state twins render the same unit card")
	game.playing=false;game.queue_free();await process_frame
	print("HUD EXPERIMENT 06 ",checks-failures,"/",checks);quit(1 if failures else 0)
