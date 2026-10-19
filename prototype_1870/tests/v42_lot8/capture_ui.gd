extends SceneTree
var game
func _initialize():call_deferred("run")
func capture(name):
	await process_frame;await process_frame
	await RenderingServer.frame_post_draw
	print("CAPTURE ",name," ",get_root().get_texture().get_image().get_size())
	get_root().get_texture().get_image().save_png("user://"+name+".png")
func run():
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop()
	game.scenario_choice="v42_lot8";game.show_camp_choice();await capture("01_menu_1280")
	game.new_game(0);game.ai_enabled=false;game.music_player.stop();await capture("02_battle_1280")
	var e=game.engine
	e.apply_losses(0,17);e.apply_losses(34,23);e.end_side();e.end_side();game.show_journal();await capture("03_journal_1280");game.close_modal()
	root.size=Vector2i(1520,720);await process_frame;await process_frame;game.refresh();await capture("04_battle_1520")
	e.state.units[0].cell=[12,9];e.state.units[34].cell=[14,9];e.state.units[0].command_ok=false;e.state.units[0].supply_ok=false
	game.map.focus=game.map.world(e.unit_cell(e.state.units[0]));game.map.zoom=1.4;game.map.queue_redraw();await capture("05_isolation_1520")
	for is_cannon in [false,true]:
		var shooter=0
		if is_cannon:
			for n in range(e.state.units.size()):
				if e.alive(n) and e.artillery(n) and int(e.state.units[n].side)==0:shooter=n;break
			e.state.units[0].cell=[10,8];e.state.units[shooter].cell=[12,9];e.state.units[shooter].deployed=true
		var event=e.combat_event(shooter,34,"fire");game.map.animate_fire(event,"",is_cannon);game.map.set_process(false)
		game.map.combat_ttl=game.map.combat_duration*0.85;game.map.queue_redraw();await capture("06_cannon" if is_cannon else "06_infantry")
		game.map.combat_ttl=game.map.combat_duration*0.45;game.map.queue_redraw();await capture("07_cannon" if is_cannon else "07_infantry")
	game.map.combat_ttl=0;game.map.set_process(true);game.new_game(1);game.ai_enabled=false;game.music_player.stop();e=game.engine
	var reserve=e.unit_index("v42_de_reserve_01");e.state.units[reserve].pending=false;e.state.units[reserve].strength=e.state.units[reserve].initial_strength;e.state.units[reserve].ap=8;e.state.units[reserve].done=false;e.state.units[reserve].cell=[12,9];e.state.units[reserve].command_ok=false;e.state.units[reserve].supply_ok=false
	e.state.human_side=1;e.state.side=1;e.refresh_intel();game.selected=reserve;game.map.focus=game.map.world(e.unit_cell(e.state.units[reserve]));game.map.zoom=1.4;game.refresh();game.map.queue_redraw();print("RESERVE FIXTURE ",reserve," ",e.state.units[reserve].number," human ",e.state.human_side);await capture("08_reserve_number_and_border")
	game.queue_free();await process_frame;quit()
