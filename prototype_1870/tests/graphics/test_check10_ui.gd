extends SceneTree
var game
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1280,720)
	game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop();game.new_game(0);game.ai_enabled=false;game.music_player.stop()
	var e=game.engine
	for u in e.state.units:u.pending=false;u.strength=0;u.casualties=u.initial_strength;u.prisoners=0;u.done=true;u.ap=0
	var ids=["fr_9","fr_25","art_fr_Raoult0"];var units=[];var candidates=[]
	for pos in range(600):
		if e.pack.map.tiles[pos]=="plain":candidates.append(pos)
	var center=e.index(Vector2i(13,8));candidates.sort_custom(func(a,b):return e.distance(a,center)<e.distance(b,center))
	for id in ids:
		var n=e.unit_index(id);var u=e.state.units[n]
		u.pending=false;u.strength=u.initial_strength;u.casualties=0;u.prisoners=0;u.ap=2;u.done=false;u.morale="stable";u.entrenched=false;u.formation="line";u.deployed=e.artillery(n);u.river_halt=false
		for pos in candidates:
			if e.unit_at(pos)>=0:continue
			var close=false
			for placed in units:
				if e.distance(pos,e.unit_cell(e.state.units[placed]))<2:close=true
			if close:continue
			var can_step=false
			for next in e.neighbours(pos):
				var cost=e.step_cost(n,pos,next)
				if cost>0 and cost<=2:can_step=true
			if can_step!=e.cavalry(n) and not e.artillery(n):continue
			u.cell=[e.cell(pos).x,e.cell(pos).y];break
		units.append(n)
	e.refresh_intel();game.map.focus=game.map.world(e.unit_cell(e.state.units[units[0]]));game.map.zoom=1.35
	game.selected=units[0];var before=JSON.stringify(e.state);game.refresh()
	check(game.map.exhausted[units[0]] and not game.map.exhausted[units[1]] and game.map.exhausted[units[2]],"infantry/cannon checked at 0.5 AP; cavalry with a move stays available")
	check(game.availability.count==1,"available counter counts legal actions rather than positive AP")
	game.next_unit();check(game.selected==units[1],"next unit skips both exhausted units")
	game.on_cell(e.unit_cell(e.state.units[units[0]]))
	check(game.selected==units[0] and game.context_detail.text==game.t("hint_done"),"checked unit stays inspectable with accurate hint")
	check(game.unit_ap.text.contains("0,5") and JSON.stringify(e.state)==before,"UI keeps unused half AP and all live engine fields")
	e.state.units[units[0]].ap=4;game.refresh();check(not game.map.exhausted[units[0]],"check clears when formation change becomes affordable")
	e.state.units[units[0]].ap=2;game.refresh()
	var args=OS.get_cmdline_user_args()
	if args.size()>0 and DisplayServer.get_name()!="headless":
		for k in range(units.size()):
			game.selected=units[k];game.clear_preview();game.map.focus=game.map.world(e.unit_cell(e.state.units[units[k]]));game.refresh()
			for frame in range(4):await process_frame;await RenderingServer.frame_post_draw
			check(root.get_texture().get_image().save_png(args[0]+"/coche_05_"+str(k)+".png")==OK,"actual half-AP screenshot")
	game.playing=false;game.queue_free();await process_frame;print("CHECK UI 10 ",checks-failures,"/",checks);quit(1 if failures else 0)
