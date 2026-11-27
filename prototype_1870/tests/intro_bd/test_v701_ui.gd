extends SceneTree
var checks=0
var failures=0
var game
var out=""
func check(ok: bool,label: String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func frame():
 await process_frame
 if DisplayServer.get_name()!="headless":await RenderingServer.frame_post_draw
func capture(name: String):
 await frame()
 if not out.is_empty() and DisplayServer.get_name()!="headless":check(root.get_texture().get_image().save_png(out+"/"+name+".png")==OK,"actual screenshot "+name)
func _initialize():call_deferred("run")
func run():
 var args=OS.get_cmdline_user_args()
 if not args.is_empty():out=args[0]
 root.size=Vector2i(1280,720)
 game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.music_player.stop();await frame()
 check(not game.has_save,"fresh isolated menu")
 var before=JSON.stringify(game.engine.state)
 await capture("menu")
 game.HistoricalIntro.open(game);await frame()
 var view=game.modal_box.get_node_or_null("Introduction1870")
 check(view!=null and view.ART.size()==6,"same six-panel BD2 opens")
 check(JSON.stringify(game.engine.state)==before,"opening BD does not change battle")
 await capture("bd2")
 view.skip_button.pressed.emit();await frame()
 check(game.modal_box.get_node_or_null("Introduction1870")==null,"skip closes BD immediately")
 check(JSON.stringify(game.engine.state)==before and not FileAccess.file_exists(game.saver.path),"skip leaves battle and original slot untouched")
 await capture("battle_choice")
 game.playing=false;game.queue_free();await frame()
 print("V70.1 UI ",checks-failures,"/",checks);quit(1 if failures else 0)
