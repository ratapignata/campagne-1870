extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func _initialize():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));var e=Rules.new(p)
	var gun=-1;var foe=-1
	for n in range(e.state.units.size()):
		if e.artillery(n) and int(e.state.units[n].side)==1:gun=n
		if not e.artillery(n) and int(e.state.units[n].side)==0:foe=n
	for u in e.state.units:u.strength=0
	e.pack.rules.fog.enabled=false;e.state.side=1
	for i in range(600):e.pack.map.tiles[i]="plain";e.pack.map.elevations[i]=0
	var a=e.state.units[gun];var b=e.state.units[foe]
	a.cell=[10,2];a.strength=a.initial_strength;a.pending=false;a.deployed=true;a.ap=16;a.done=false
	b.cell=[10,4];b.strength=b.initial_strength;b.pending=false
	e.pack.map.elevations[100]=2
	check(e.fire_status(gun,foe)=="blocked_terrain","intermediate height blocks plain shot")
	check(not e.artillery_fire_cells(gun).has(130),"blocked target not highlighted")
	var r=RandomNumberGenerator.new();r.seed=42;var elevated_loss=e.shot_loss(gun,foe,r)
	e.pack.map.elevations[100]=0;r.seed=42
	check(e.shot_loss(gun,foe,r)==elevated_loss,"no height damage penalty")
	for terrain in ["forest","village"]:
		e.pack.map.tiles[100]=terrain
		check(e.fire_status(gun,foe)=="blocked_cover","blocked reason "+terrain)
		check(not e.artillery_fire_cells(gun).has(130),"blocked target never illuminated "+terrain)
	e.pack.map.tiles[100]="cultivated";e.pack.map.elevations[100]=2
	check(e.fire_status(gun,foe)=="blocked_terrain","cultivated height also intersects sight ray")
	e.pack.map.tiles[100]="plain";e.pack.map.elevations[100]=0
	b.cell=[10,10]
	check(e.fire_status(gun,foe)=="ok","Krupp reaches eight hexes")
	b.cell=[10,11];check(e.fire_status(gun,foe)=="range","nine hexes out of range")
	check(e.weapon(gun).distance_factors.slice(6)==[0.35,0.25],"long range factors")
	for w in p.weapons.values():
		if w.get("requires_deployment",false) and w!=p.weapons.krupp:check(int(w.range)==6,"French guns remain range six")
	e=Rules.new(p)
	check(e.bridge_turns.has("343:344") and not e.bridge_turns.has("344:345"),"bridge moved to left road crossing")
	check(e.road_links.has("343:344") and not e.road_links.has("344:345"),"road crossing matches bridge")
	for edge in p.map.road_edges:check(e.distance(int(edge[0]),int(edge[1]))==1,"adjacent road endpoints")
	for edge in [[95,65],[65,35],[35,5]]:
		check(e.road_links.has(e.river_key(edge[0],edge[1])) and not e.open_river(edge[0],edge[1]),"connected route to Reichshoffen")
	check(int(p.map.road_exits[0].cell[0])==5 and int(p.map.road_exits[0].cell[1])==0,"road reaches map border")
	var visited={5:true};var queue=[5]
	while not queue.is_empty():
		var cell=queue.pop_front()
		for next in e.neighbours(cell):
			if e.road_links.has(e.river_key(cell,next)) and not visited.has(next):visited[next]=true;queue.append(next)
	check(visited.size()>40,"Reichshoffen connected to main road network")
	# The lightweight AI engine consumes exactly the sanitized snapshot, not pack units.
	var view=e.observation(0);var simulated=Rules.new(view.pack,view.state)
	check(simulated.state==view.state,"AI snapshot state preserved")
	check(simulated.vision_cache.is_empty(),"no live intelligence initialized for AI snapshot")
	simulated.state.units[0].ap=0;check(view.state.units[0].ap!=0,"AI simulations cannot mutate caller snapshot")
	print("RELEASE 0830 ",checks-failures,"/",checks);quit(1 if failures else 0)
