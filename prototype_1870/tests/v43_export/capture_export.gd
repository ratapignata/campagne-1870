extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720);var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();game.new_game(0);game.show_menu()
 await process_frame;await process_frame
 root.get_texture().get_image().save_png("user://export_menu.png")
 game.show_export_notice(true);await process_frame;await process_frame
 root.get_texture().get_image().save_png("user://export_success.png")
 game.playing=false;game.queue_free();await process_frame;quit()
