extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func _initialize():call_deferred("run")
func run():
	var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop()
	await process_frame
	game.scenario_choice="historical";game.new_game(0);game.ai_enabled=false
	var e=game.engine;var hq=-1;var foot=-1;var foe=-1
	for n in range(e.state.units.size()):
		if e.alive(n) and int(e.state.units[n].side)==0:
			if e.headquarters(n):hq=n
			elif not e.artillery(n) and not e.cavalry(n):foot=n
		elif e.alive(n) and int(e.state.units[n].side)==1:foe=n
	game.map.selected=hq;game.map.target=-1
	var count=0;var correct=true
	for n in range(e.state.units.size()):
		var expected=e.alive(n) and n!=hq and e.state.units[n].side==0 and e.state.units[n].command_group==e.state.units[hq].command_group
		correct=correct and game.map.hq_member_highlighted(n)==expected
		if expected:count+=1
	check(correct and count>0,"HQ highlights exactly its living subordinates")
	game.map.selected=foot;check(not game.map.hq_member_highlighted(foot),"ordinary selection clears HQ outline")
	game.map.selected=hq;game.map.target=foe;check(not game.map.hq_member_highlighted(foot),"enemy selection clears HQ outline")
	e.pack.rules.fog.enabled=false;e.pack.map.tiles.fill("plain");e.pack.map.elevations.fill(0);e.river_links.clear();e.road_links.clear()
	for n in range(e.state.units.size()):
		if n not in [foot,foe]:e.state.units[n].strength=0
	e.state.units[foot].cell=[10,6];e.state.units[foe].cell=[10,8];e.state.units[foot].ap=16;e.state.units[foot].done=false
	game.selected=foot;game.target=-1;game.refresh()
	check(e.fire_status(foot,foe)=="ok" and game.map.fire_target_lit(foe),"infantry reachable enemy illuminated")
	e.pack.map.tiles[e.index(Vector2i(10,7))]="forest";game.refresh()
	check(e.fire_status(foot,foe)!="ok" and not game.map.fire_target_lit(foe),"forest blocked enemy not illuminated")
	e.pack.map.tiles.fill("plain");e.state.units[foot].ap=0;game.refresh();check(not game.map.fire_target_lit(foe),"no PA clears targets")
	game.playing=false;game.queue_free();await process_frame
	print("HIGHLIGHTS 0833 ",checks-failures,"/",checks);quit(1 if failures else 0)
