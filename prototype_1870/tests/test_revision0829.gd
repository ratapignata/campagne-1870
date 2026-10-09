extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func _initialize():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));var e=Rules.new(p)
	var foot=0;var horse=-1;var cannon=-1
	for n in range(e.state.units.size()):
		if e.cavalry(n):horse=n
		if e.artillery(n):cannon=n
	e.state.units[horse].strength=int(e.state.units[horse].initial_strength);e.state.units[horse].pending=false
	# Road costs depend on connected edges, not decoration on either endpoint.
	var a=310;var b=340
	e.pack.map.tiles[b]="cultivated";e.river_links.clear();e.road_links[e.river_key(a,b)]=true
	check(e.step_cost(foot,a,b)==2,"column on road costs .5 PA")
	check(e.step_cost(horse,a,b)==1,"cavalry on road costs .25 PA")
	e.road_links.erase(e.river_key(a,b))
	check(e.step_cost(foot,a,b)==5,"leaving road into crops costs 1.25 PA in column")
	check(e.step_cost(horse,a,b)==6,"cavalry leaving road costs 1.5 PA")
	e.river_links[e.river_key(a,b)]=false;e.road_links[e.river_key(a,b)]=true
	check(e.step_cost(foot,a,b)==13,"road does not erase unbridged river penalty")
	check(not e.edge_allowed(horse,a,b),"horse still needs bridge")
	e=Rules.new(p)
	e.state.turn=3;check(e.open_river(344,345),"Woerth closed turn 3");check(not e.edge_allowed(cannon,344,345),"cannon blocked before opening")
	e.state.turn=4;check(not e.open_river(344,345),"Woerth opens turn 4");check(e.edge_allowed(cannon,344,345),"cannon crosses after opening")
	check(e.step_cost(foot,344,345)==2,"bridge road has road cost")
	var copy=Rules.new(p);copy.state=JSON.parse_string(JSON.stringify(e.state));copy.normalize();check(not copy.open_river(344,345),"bridge stays open after save roundtrip")
	# Explicit physical firing tests on a controlled straight line.
	e=Rules.new(p)
	for u in e.state.units:u.strength=0
	for i in range(600):e.pack.map.tiles[i]="plain";e.pack.map.elevations[i]=0
	e.pack.rules.fog.enabled=false
	e.state.units[cannon].cell=[10,2];e.state.units[cannon].strength=250;e.state.units[cannon].side=0
	var start=70;var finish=190;var mid=100
	e.pack.map.elevations[mid]=1
	check(e.line_status(start,finish)=="ok","minor plain elevation does not block")
	e.pack.map.elevations[mid]=2
	check(e.line_status(start,finish)=="blocked_terrain","marked height still blocks")
	e.pack.map.elevations[mid]=0;e.pack.map.tiles[mid]="forest"
	check(e.line_status(start,finish)=="blocked_cover","wood still blocks")
	e.pack.map.tiles[mid]="plain";e.state.units[foot].cell=[10,3];e.state.units[foot].strength=2000;e.state.units[foot].side=0
	check(e.line_status(start,finish)=="blocked_friendly","flat friendly blocking preserved")
	e.pack.map.elevations[start]=2
	check(e.line_status(start,finish)=="ok","elevated gun shoots over friend")
	e.pack.map.elevations[start]=0;e.state.units[foot].strength=0
	e.pack.map.tiles[mid]="cultivated"
	check(e.line_status(start,finish)=="ok","crops do not block")
	print("REVISION 0829 ",checks-failures,"/",checks);quit(1 if failures else 0)
