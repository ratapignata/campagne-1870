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
	game.scenario_choice="v42_experimental";game.show_camp_choice();await capture("01_menu_1280")
	game.new_game(0);game.ai_enabled=false;game.music_player.stop();await capture("02_battle_1280")
	var e=game.engine
	e.apply_losses(0,17);e.apply_losses(34,23);e.end_side();e.end_side();game.show_journal();await capture("03_journal_1280");game.close_modal()
	root.size=Vector2i(1520,720);await process_frame;await process_frame;game.refresh();await capture("04_battle_1520")
	e.state.units[0].cell=[12,9];e.state.units[34].cell=[14,9];e.state.units[0].command_ok=false;e.state.units[0].supply_ok=false
	game.map.queue_redraw();await capture("05_isolation_1520")
	for is_cannon in [false,true]:
		var event=e.combat_event(0,34,"fire");game.map.animate_fire(event,"",is_cannon);game.map.set_process(false)
		game.map.combat_ttl=game.map.combat_duration*0.85;game.map.queue_redraw();await capture("06_cannon" if is_cannon else "06_infantry")
		game.map.combat_ttl=game.map.combat_duration*0.45;game.map.queue_redraw();await capture("07_cannon" if is_cannon else "07_infantry")
	game.queue_free();await process_frame;quit()
