extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
var checks=0
var failures=0
func check(ok:bool,msg:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+msg)
func revive(e,n,c):
	var u=e.state.units[n];u.cell=c;u.strength=u.initial_strength;u.casualties=0;u.done=false;u.ap=e.max_ap(n);u.morale="stable"
func fresh(corridor:bool):
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/historical_trial.json"));p.rules.fog.enabled=false;p.map.tiles.fill("water" if corridor else "plain");p.map.elevations.fill(0);p.map.river_edges=[];p.rules.support.supply_sources=[[[2,1]],[[28,18]]]
	if corridor:
		for y in range(1,19):p.map.tiles[y*30+2]="plain"
	var e=Rules.new(p)
	for n in range(e.state.units.size()):
		var u=e.state.units[n];u.cell=[28,n];u.strength=0;u.casualties=u.initial_strength;u.done=true
	revive(e,12,[2,1]);revive(e,0,[2,9]);e.refresh_support();return e
func _initialize():
	var e=fresh(false);revive(e,4,[2,5]);e.refresh_support()
	check(e.state.units[0].command_ok and e.state.units[0].supply_ok,"enemy behind can be bypassed on open terrain")
	e.state.units[0].cell=[2,17];e.refresh_support();check(not e.state.units[0].command_ok and e.state.units[0].supply_ok,"distant unit out of command but supply route exists")
	e=fresh(true);check(e.state.units[0].command_ok and e.state.units[0].supply_ok,"open corridor supplies and commands")
	revive(e,4,[2,5]);e.refresh_support();check(not e.state.units[0].supply_ok and not e.state.units[0].command_ok,"occupied bottleneck cuts both")
	e.state.units[4].cell=[3,5];e.pack.map.tiles[153]="plain";e.refresh_support();check(not e.state.units[0].supply_ok and not e.state.units[0].command_ok,"enemy adjacent ZOC cuts both")
	e.pack.map.tiles[154]="plain";e.state.side=1;var moved=e.move(4,[153,154]);check(moved in ["moved","capture","discovered"] and e.state.units[0].supply_ok and e.state.units[0].command_ok,"enemy movement away immediately restores both")
	check(e.undo() and not e.state.units[0].supply_ok and not e.state.units[0].command_ok,"undo refreshes both links")
	e=fresh(true);e.river_links[e.river_key(152,182)]=false;e.refresh_support();check(not e.state.units[0].command_ok and not e.state.units[0].supply_ok,"river without bridge cuts both")
	e.river_links[e.river_key(152,182)]=true;e.refresh_support();check(e.state.units[0].supply_ok and e.state.units[0].command_ok,"bridge restores links")
	e.state.units[12].morale="routed";e.refresh_support();check(not e.state.units[0].command_ok and e.state.units[0].supply_ok,"routed HQ interrupts command independently")
	e=fresh(false)
	var ring=e.neighbours(e.unit_cell(e.state.units[0]));var foes=[4,5,6,7,9,11]
	for k in range(6):
		var c=e.cell(ring[k]);revive(e,foes[k],[c.x,c.y])
	e.refresh_support();check(not e.state.units[0].supply_ok and not e.state.units[0].command_ok and e.state.units[0].encircled,"full encirclement blocks all three links")
	e.state.units[0].ammo_level=2;e.state.units[0].attacked=false;e.end_side();e.end_side()
	check(e.state.units[0].ammo_level==2,"isolated unit cannot recover ammunition")
	for name in ["prototype","three_objectives","historical_trial"]:
		var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/"+name+".json"));p.rules.fog.enabled=false;p.map.tiles.fill("cultivated");p.map.elevations.fill(0);e=Rules.new(p)
		for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,18]
		e.state.units[8].cell=[10,3];e.state.units[8].deployed=true;e.state.units[4].cell=[10,8]
		check(e.fire_status(8,4)=="ok" and e.artillery_fire_cells(8).has(250),name+" crops do not obstruct cannon")
		e.pack.map.elevations[160]=2;check(e.fire_status(8,4)=="blocked_terrain",name+" relief independently blocks")
		check(is_equal_approx(float(p.terrains.cultivated.fire_received),.85),name+" modest protection retained")
	print("SUPPLY CROPS 0826 ",checks-failures,"/",checks);quit(1 if failures else 0)
