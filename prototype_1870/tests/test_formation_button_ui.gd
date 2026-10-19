extends SceneTree
var failures=0
var checks=0
var game
var taps=0
func _initialize():call_deferred("run")
func check(ok: bool,name: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+name)
	else:print("PASS: "+name)
func touch(pos: Vector2,pressed: bool,index: int=0):
	var event=InputEventScreenTouch.new();event.position=pos;event.pressed=pressed;event.index=index
	Input.parse_input_event(event);await process_frame
func tap(pos: Vector2):
	await touch(pos,true);await touch(pos,false);await process_frame
func drag(pos: Vector2,delta: Vector2,index: int=0):
	var event=InputEventScreenDrag.new();event.position=pos;event.relative=delta;event.index=index
	Input.parse_input_event(event);await process_frame
func mouse_click(pos: Vector2):
	for pressed in [true,false]:
		var event=InputEventMouseButton.new();event.position=pos;event.global_position=pos;event.pressed=pressed;event.button_index=MOUSE_BUTTON_LEFT;event.device=0
		Input.parse_input_event(event);await process_frame
	await process_frame
func find_button(node: Node,value: String) -> Button:
	if node is Button and node.text==value and node.is_visible_in_tree():return node
	for child in node.get_children():
		var result=find_button(child,value)
		if result!=null:return result
	return null
func press(key: String):
	var b=find_button(game,game.t(key))
	if b==null:check(false,"missing button "+key);return
	await tap(b.get_global_rect().get_center())
func tap_cell(index: int):await tap(game.map.screen(index)+game.map.position)
func screenshot(name: String):
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../releases/"+name+("_large" if root.get_visible_rect().size.x>1280 else "")+".png")
func setup_case():
	game.close_modal();game.engine.new_game(1);game.engine.state.side=1;game.selected=-1;game.clear_preview();game.map.combat_ttl=0;game.map.feedback_ttl=0
	game.engine.pack.map.tiles.fill("plain")
	for n in range(game.engine.state.units.size()):game.engine.state.units[n].cell=[n*2,18]
	game.engine.state.units[6].cell=[8,8]
	game.engine.pack.map.tiles[game.engine.index(Vector2i(9,8))]="road"
	game.map.zoom=1.0;game.map.focus=game.map.world(game.engine.index(Vector2i(9,8)));game.refresh();await process_frame
	await tap_cell(game.engine.unit_cell(game.engine.state.units[6]))
	var dest=game.engine.index(Vector2i(10,8));await tap_cell(dest);await tap_cell(dest)
	check(game.engine.state.units[6].ap==11 and not game.engine.previous.is_empty(),"Prussian infantry 3 moved two cells, 2.75 AP, undo available")
func run():
	game=load("res://main.tscn").instantiate();game.prefs_path="user://formation_button_ui.cfg";root.add_child(game)
	game.saver=load("res://war_engine/platform/save_store.gd").new("user://formation_button_ui_save.json","formation-button-ui")
	game.ai_enabled=true;game.playing=true
	await process_frame
	for n in [6,5,7,4]:
		await setup_case()
		if n!=6:
			game.map.focus=game.map.world(game.engine.unit_cell(game.engine.state.units[n]));await process_frame
			await tap_cell(game.engine.unit_cell(game.engine.state.units[n]))
		var ap_before=int(game.engine.state.units[n].ap)
		check(ap_before==(11 if n==6 else 16),"selected infantry %d has expected AP"%(n-3))
		check(game.formation_button.visible and not game.formation_button.disabled,"formation button enabled infantry %d"%(n-3))
		check(not game.formation_button.get_global_rect().intersects(game.actions.entrench.get_global_rect()),"formation and entrench do not overlap infantry %d"%(n-3))
		for key in ["undo","entrench"]:
			check(not game.actions[key].get_global_rect().intersects(game.formation_button.get_global_rect()),"distinct hit area "+key)
		check(game.context_label.get_theme_font("font").get_string_size(game.context_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,22).x<=game.context_label.size.x,"undo header fits")
		if n==6:await screenshot("1870_v083_formation_button")
		await tap(game.formation_button.get_global_rect().get_center())
		check(is_instance_valid(game.modal),"touch opens formation dialog infantry %d"%(n-3))
		check(game.engine.state.units[n].ap==ap_before and not game.engine.state.units[n].entrenched,"opening formation does not entrench or spend AP infantry %d"%(n-3))
		if is_instance_valid(game.modal):
			await press("formation_line")
			check(game.engine.formation(n)=="line" and game.engine.state.units[n].ap==ap_before-4,"column to line spends exactly 1 PA infantry %d"%(n-3))
	await setup_case()
	await tap(game.actions.undo.get_global_rect().get_center())
	check(game.engine.state.units[6].ap==16 and game.engine.state.units[6].cell==[8,8] and game.engine.previous.is_empty(),"undo remains accessible and restores move")
	await setup_case();await tap(game.actions.entrench.get_global_rect().get_center())
	check(game.engine.state.units[6].entrenched and game.engine.state.units[6].ap==3,"entrench remains accessible and costs 2 PA")
	game.engine.state.units[6].ap=11;game.engine.state.units[6].done=false;game.refresh()
	await tap(game.formation_button.get_global_rect().get_center());check(is_instance_valid(game.modal),"formation still opens after entrenchment")
	if is_instance_valid(game.modal):await press("formation_line")
	check(game.engine.formation(6)=="line" and game.engine.state.units[6].ap==7 and game.engine.state.units[6].entrenched,"formation after entrenchment costs 1 PA and preserves shelter")
	game.close_modal();game.playing=false;game.set_process(false)
	for player in [game.music_player,game.sound_player,game.reaction_player,game.assault_player]:player.stop();player.stream=null
	await create_timer(0.3).timeout
	game.queue_free();await process_frame;await process_frame;game=null
	for name in ["formation_button_ui.cfg","formation_button_ui_save.json","formation_button_ui_save.json.bak"]:DirAccess.remove_absolute("user://"+name)
	print("FORMATION BUTTON UI: %d passed / %d total"%[checks-failures,checks]);quit(1 if failures else 0)
