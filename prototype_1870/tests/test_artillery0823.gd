extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
var checks=0
var failures=0
func check(ok: bool,label: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func fixture():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json"))
	p.map.tiles.fill("plain");p.map.elevations.fill(0);p.rules.fog.enabled=false
	var e=Rules.new(p)
	for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,18]
	e.state.units[8].cell=[10,3];e.state.units[8].deployed=true;e.state.units[4].cell=[10,8]
	return e
func _initialize():
	var e=fixture();var dest=e.unit_cell(e.state.units[4]);var middle=e.index(Vector2i(10,5));var before=e.state.duplicate(true)
	check(e.artillery_fire_cells(8).has(dest) and e.fire_status(8,4)=="ok","clear destination")
	check(e.state==before,"overlay does not change game state")
	check(not e.artillery_fire_cells(8).has(e.unit_cell(e.state.units[8])),"own cannon excluded")
	e.state.units[0].cell=[10,5]
	check(not e.artillery_fire_cells(8).has(dest) and e.fire_status(8,4)=="blocked_friendly","friendly blocker")
	check(not e.artillery_fire_cells(8).has(middle),"friendly destination excluded")
	e.state.units[0].cell=[0,18];e.pack.map.elevations[middle]=2
	check(not e.artillery_fire_cells(8).has(dest) and e.fire_status(8,4)=="blocked_terrain","hill blocker")
	e.pack.map.elevations[middle]=0;e.pack.map.tiles[middle]="forest"
	check(not e.artillery_fire_cells(8).has(dest) and e.fire_status(8,4)=="blocked_cover","forest blocker")
	e.pack.map.tiles[middle]="plain";e.state.units[5].cell=[10,5]
	check(not e.artillery_fire_cells(8).has(dest) and e.artillery_fire_cells(8).has(middle),"visible nearer enemy blocks beyond, not its own case")
	e=fixture();e.state.units[8].deployed=false;check(e.artillery_fire_cells(8).is_empty(),"limbered")
	e.state.units[8].deployed=true;e.state.units[8].ap=4;check(e.artillery_fire_cells(8).is_empty(),"insufficient AP")
	e.state.units[8].ap=16;e.state.units[8].morale="routed";check(e.artillery_fire_cells(8).is_empty(),"routed")
	e=fixture();e.state.units[4].cell=[10,10];check(not e.artillery_fire_cells(8).has(e.unit_cell(e.state.units[4])),"out of range")
	for side in [0,1]:
		e=fixture();e.state.side=side;var shooter=8+side;var victim=4 if side==0 else 0
		e.state.units[8].cell=[0,18];e.state.units[shooter].cell=[10,3];e.state.units[shooter].deployed=true
		for i in range(e.width*e.height):
			if e.unit_at(i)>=0:continue
			e.state.units[victim].cell=[e.cell(i).x,e.cell(i).y]
			check(e.artillery_fire_cells(shooter).has(i)==(e.fire_status(shooter,victim)=="ok"),"overlay/shot parity side %d cell %d"%[side,i])
	# Hidden unit cannot change the overlay, including its own cell.
	e=fixture();e.pack.rules.fog.enabled=true;e.state.units[5].cell=[10,8];e.state.units[4].cell=[10,9];e.refresh_intel()
	check(not e.visible_to(0,5),"fog fixture hidden")
	var hidden=e.artillery_fire_cells(8);e.state.units[5].cell=[28,18];e.refresh_intel()
	check(hidden==e.artillery_fire_cells(8),"hidden blocker does not leak through overlay")
	print("ARTILLERY 0823 ",checks-failures,"/",checks);quit(1 if failures else 0)
