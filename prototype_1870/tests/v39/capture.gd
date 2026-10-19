extends SceneTree
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1280,720)
	var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.sound_enabled=false
	game.scenario_choice="historical";game.new_game(0);game.close_modal();game.playing=true;game.refresh()
	for z in [.72,1.18,2.3]:
		game.map.zoom=z
		var curve=game.map.Cartography.river_curve(game.map)
		game.map.focus=curve.sample_baked(curve.get_baked_length()/2)+Vector2(0,70)
		game.map.queue_redraw()
		await process_frame;await process_frame;await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/results/0839/sauer_"+str(z)+".png")
	game.show_camp_choice();await process_frame;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/results/0839/menu.png")
	game.queue_free();await process_frame;quit()
