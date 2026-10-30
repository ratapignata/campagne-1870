extends SceneTree
var checks=0
var failures=0
func check(ok,msg):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",msg)
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720);var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop();game.difficulty_choice="hard";game.new_game(1);game.ai_enabled=false;game.music_player.stop()
 check(game.engine.state.human_side==1 and game.engine.state.side==0 and game.engine.state.ai_difficulty=="hard","real application starts Prussian player against French Hard")
 var observation=game.engine.observation(0);var before=observation.duplicate(true);var worker=Thread.new();var generation=game.ai_generation
 check(worker.start(game.compute_ai.bind(observation,generation))==OK,"French defensive planner starts through production worker")
 var result=worker.wait_to_finish();var decision=result.decision
 check(result.generation==generation and game.ai.hard_defensive and not game.ai.hard_offensive,"worker selects correct defensive doctrine and generation")
 check(observation==before,"worker does not mutate shared observation")
 var previous=JSON.stringify(game.engine.state);game.apply_ai_decision(decision)
 check(JSON.stringify(game.engine.state)!=previous and game.engine.validate(game.engine.state),"production dispatcher executes legal French order")
 check(game.engine.state.side==0,"French AI remains active until its phase ends")
 check(game.saver.load_game(game.engine),"autosave after defensive order can reload")
 check(game.engine.state.human_side==1 and game.engine.state.ai_difficulty=="hard","reload retains camp and difficulty")
 game.playing=false;game.queue_free();await process_frame
 print("V43.15 FRENCH UI ",checks-failures,"/",checks);quit(1 if failures else 0)
