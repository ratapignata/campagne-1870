extends SceneTree
var game
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func picture(path: String):
	if DisplayServer.get_name()=="headless" or path.is_empty():return
	for k in range(2):await process_frame;await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(path)==OK,"actual feedback screenshot written")
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1280,720)
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop();game.new_game(0);game.ai_enabled=false;game.music_player.stop()
	var e=game.engine;var n=e.unit_index("fr_9");game.selected=n;game.clear_preview();game.refresh();var hud=game.hud_details
	check(hud.feedback_pulses.is_empty() and not hud.is_processing(),"first display never flashes or starts continuous polling")
	var state=JSON.stringify(e.state);var undo=JSON.stringify(e.previous)
	for k in range(4):game.refresh()
	check(hud.feedback_pulses.is_empty() and JSON.stringify(e.state)==state and JSON.stringify(e.previous)==undo,"idempotent refresh is read-only and does not flash")
	var moved=false
	for key in e.reach(n).costs:
		var cell=int(key)
		if cell==e.unit_cell(e.state.units[n]) or e.known_unit_at(cell,0)>=0:continue
		var outcome=e.move(n,e.path_to(n,cell));moved=outcome in ["moved","capture","discovered"];break
	check(moved,"actual legal move used to exercise AP change")
	state=JSON.stringify(e.state);undo=JSON.stringify(e.previous);game.refresh()
	check(hud.feedback_pulses.has("ap") and hud.feedback_pulses.size()==1,"actual AP expenditure highlights only displayed AP")
	var geometry=[game.unit_info.get_rect(),game.unit_ap.get_rect(),game.unit_state.get_rect()]
	hud._process(0.2);var remaining=float(hud.feedback_pulses.get("ap",0));game.refresh()
	check(is_equal_approx(float(hud.feedback_pulses.get("ap",0)),remaining),"unchanged refresh does not restart the pulse")
	check(JSON.stringify(e.state)==state and JSON.stringify(e.previous)==undo,"feedback cannot mutate game or undo state")
	hud._process(1.0)
	check(hud.feedback_pulses.is_empty() and not hud.is_processing(),"pulse expires and per-frame processing stops")
	var args=OS.get_cmdline_user_args();var out=args[0] if args.size()>0 else ""
	if not out.is_empty():await picture(out+"/fiche_avant.png")
	var u=e.state.units[n];u.strength-=50;u.casualties+=50;u.morale="shaken";u.ap=maxi(0,int(u.ap)-1)
	state=JSON.stringify(e.state);undo=JSON.stringify(e.previous);game.refresh()
	for key in ["ap","strength","morale"]:check(hud.feedback_pulses.has(key),"public change highlighted: "+key)
	check(geometry==[game.unit_info.get_rect(),game.unit_ap.get_rect(),game.unit_state.get_rect()],"card values retain their original rectangles")
	check(hud.mouse_filter==Control.MOUSE_FILTER_IGNORE,"feedback never intercepts touches")
	if not out.is_empty():await picture(out+"/fiche_pendant.png")
	hud._process(1.0)
	if not out.is_empty():await picture(out+"/fiche_apres.png")
	check(JSON.stringify(e.state)==state and JSON.stringify(e.previous)==undo,"drawing and expiry do not issue orders")
	game.selected=e.unit_index("fr_10");game.refresh()
	check(hud.feedback_pulses.is_empty(),"switching unit does not report its different values as changes")
	game.selected=n;game.refresh();check(hud.feedback_pulses.is_empty(),"returning to a unit starts a new baseline")
	var enemy=e.unit_index("pru_36");game.target=enemy;game.refresh()
	# Explicit unknown card, even if the normal refresh deselected the unseen target.
	game.target=enemy;game.unit_info.text=game.t("fog_no_state");game.unit_ap.text="";hud.update_details()
	check(hud.feedback_pulses.is_empty() and not hud.is_processing(),"enemy card has no feedback of hidden values")
	var saved=e.state.units[enemy].duplicate(true)
	e.state.units[enemy].strength=1;e.state.units[enemy].morale="routed";e.state.units[enemy].ap=0;hud.update_details()
	check(hud.feedback_pulses.is_empty(),"hidden-world twin cannot create feedback")
	e.state.units[enemy]=saved;game.target=-1;game.selected=n;game.refresh()
	u=e.state.units[n];u.ap+=1;game.refresh();check(hud.feedback_pulses.has("ap"),"feedback resumes on a subsequent actual own value change")
	var restored=game.EngineRules.new(e.pack,e.state);game.engine=restored;game.map.engine=restored;game.refresh()
	check(hud.feedback_pulses.is_empty() and not hud.is_processing(),"loaded/new engine never inherits stale pulses")
	game.unit_ap.text="";hud.update_details();check(hud.feedback_values.is_empty(),"unknown/empty card clears feedback history")
	game.playing=false;game.queue_free();await process_frame;print("FEEDBACK 12 ",checks-failures,"/",checks);quit(1 if failures else 0)
