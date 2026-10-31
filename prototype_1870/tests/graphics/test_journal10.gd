extends SceneTree
const Model=preload("res://war_engine/presentation/journal_model.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var game
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func tap(area):
	var event=InputEventScreenTouch.new();event.index=0;event.position=area.get_global_rect().get_center();event.pressed=true;Input.parse_input_event(event);await process_frame
	event=InputEventScreenTouch.new();event.index=0;event.position=area.get_global_rect().get_center();event.pressed=false;Input.parse_input_event(event);await process_frame
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1280,720)
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop();game.new_game(0);game.ai_enabled=false;game.music_player.stop()
	var pack=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));var state=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/v4313_t11_simulation.json"))
	var e=game.EngineRules.new(pack,state);e.normalize();e.refresh_intel();game.engine=e;game.map.engine=e;game.support_notice_seen=int(e.state.support_serial)
	var own=e.unit_index("fr_14")
	if not e.alive(own):
		e.state.units[own].strength=100;e.state.units[own].casualties=e.state.units[own].initial_strength-100;e.state.units[own].prisoners=0
	e.surrender(own);e.refresh_intel();game.support_notice_seen=int(e.state.support_serial);game.refresh()
	var before=JSON.stringify(e.state);var data=Model.build(game)
	check(JSON.stringify(e.state)==before,"journal model is read-only")
	check(data.summary.contains("Wœrth : 2 points") and data.summary.contains("60/20/20"),"current goals and score weights retained")
	check(not Model.filtered(data.rows,"combat").is_empty(),"combat filter has recorded battles")
	check(not Model.filtered(data.rows,"surrender").is_empty(),"surrender filter names confirmed capitulations")
	check(not Model.filtered(data.rows,"objective").is_empty(),"objective filter uses recorded captures")
	check(not Model.filtered(data.rows,"reinforcement").is_empty(),"reinforcement filter shows own arrivals/schedules")
	for category in ["combat","surrender","objective","reinforcement"]:
		for item in Model.filtered(data.rows,category):check(item.category==category,"strict category filter "+category)
	var unknown=e.unit_index("pru_57")
	# Identical recorded knowledge; arbitrary secret reinforcement/name/loss changes.
	var old_name=e.state.units[unknown].name_key;e.state.units[unknown].name_key="SECRET_SENTINEL"
	e.state.units[unknown].arrival_turn=19;e.state.units[unknown].pending=true;e.state.units[unknown].casualties+=7
	var altered=Model.build(game)
	check(JSON.stringify(altered)==JSON.stringify(data),"hidden name, losses and reinforcement schedule cannot change journal")
	check(not JSON.stringify(altered).contains("SECRET_SENTINEL"),"no secret name leak")
	e.state.units[unknown].name_key=old_name;e.state.units[unknown].casualties-=7
	for item in Model.filtered(data.rows,"reinforcement"):
		check(item.turn==-1,"unrecorded actual reinforcement dates are never invented")
		check(item.body.contains("non consignée") or item.body.contains("prévue"),"arrival status distinguishes schedule from recorded time")
	check(Model.stamp(e,20,true).contains("18:00") and Model.stamp(e,20).contains("17:30"),"end-of-turn and start-of-turn clocks distinct")
	# Reset the actual fixture; the deliberately inconsistent hidden-world twin is not saved.
	e=game.EngineRules.new(pack,state);e.normalize();e.refresh_intel();game.engine=e;game.map.engine=e
	if e.alive(own):e.surrender(own)
	e.refresh_intel()
	game.support_notice_seen=int(e.state.support_serial);game.refresh()
	var args=OS.get_cmdline_user_args();var screenshot_dir=args[0] if args.size()>0 else ""
	for dimensions in [Vector2i(1280,606),Vector2i(1280,720),Vector2i(1520,720)]:
		root.size=dimensions;await process_frame;await process_frame;game.show_journal();await process_frame;await process_frame
		var view=game.modal_box.get_node("JournalView");var box=game.modal_box.get_global_rect()
		check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(box),"journal fits screen "+str(dimensions))
		var previous_rect=Rect2()
		for category in ["all","combat","surrender","objective","reinforcement"]:
			var button=view.buttons[category]
			check(box.encloses(button.get_global_rect()),"filter button inside journal")
			if previous_rect.size.x>0:check(not previous_rect.intersects(button.get_global_rect()),"filter buttons do not overlap")
			previous_rect=button.get_global_rect();var current=JSON.stringify(e.state);var disk=FileAccess.get_file_as_string(game.saver.path)
			await tap(button);await process_frame
			check(view.selected_filter==category and button.get_meta("active"),"real touch selects "+category)
			check(view.visible_rows==Model.filtered(view.data.rows,category),"display uses actual filtered records")
			check(JSON.stringify(e.state)==current and FileAccess.get_file_as_string(game.saver.path)==disk,"filter never changes game/save")
			for child in view.list.get_children():check(child.size.x<=view.scroll.size.x+1,"row wraps within journal width")
			if screenshot_dir!="" and DisplayServer.get_name()!="headless" and dimensions==Vector2i(1280,720):
				await RenderingServer.frame_post_draw;check(root.get_texture().get_image().save_png(screenshot_dir+"/journal_"+category+".png")==OK,"actual filtered screenshot")
		view.set_filter("combat");await process_frame;await process_frame
		check(view.shown_count==mini(40,view.visible_rows.size()),"large journal starts with bounded row count")
		var count=view.shown_count;view.scroll.scroll_vertical=10000000
		for k in range(6):await process_frame
		check(view.shown_count>count or view.shown_count==view.visible_rows.size(),"scroll loads additional old entries")
		view.scroll.scroll_vertical=0;await process_frame;await process_frame
		var state_before_drag=JSON.stringify(e.state);var point=view.scroll.get_global_rect().get_center()
		var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=true;Input.parse_input_event(touch);await process_frame
		var drag=InputEventScreenDrag.new();drag.index=0;drag.position=point+Vector2(0,-120);drag.relative=Vector2(0,-120);Input.parse_input_event(drag);await process_frame
		touch=InputEventScreenTouch.new();touch.index=0;touch.position=drag.position;touch.pressed=false;Input.parse_input_event(touch);await process_frame
		check(view.scroll.scroll_vertical>0,"real finger drag scrolls the rows")
		check(view.selected_filter=="combat","drag does not change category")
		check(JSON.stringify(e.state)==state_before_drag,"drag does not issue game orders")
		view.set_filter("surrender");await process_frame
		check(view.shown_count<=40 and view.scroll.scroll_vertical==0,"filter resets scrolling and lazy loading")
		game.close_modal();await process_frame
	# New display markers and filters have no save schema fields.
	var saver=Store.new("user://journal10.json",FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json").sha256_text())
	var copy=game.EngineRules.new(pack)
	check(saver.save_game(e) and saver.load_game(copy),"journal state saves and reloads")
	var old=Model.build(game);game.engine=copy;check(Model.build(game)==old,"journal rebuilt identically after load")
	game.playing=false;game.queue_free();await process_frame;print("JOURNAL 10 ",checks-failures,"/",checks);quit(1 if failures else 0)
