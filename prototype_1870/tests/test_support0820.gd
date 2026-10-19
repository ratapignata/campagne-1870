extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok: bool,message: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+message)
func fresh(corridor=false):
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0820.json"))
	p.rules.fog.enabled=false;p.map.tiles.fill("water" if corridor else "plain");p.map.elevations.fill(0);p.map.river_edges=[]
	p.rules.support.supply_sources=[[[2,1]],[[28,18]]]
	if corridor:
		for y in range(1,19):p.map.tiles[y*30+2]="plain"
	var e=Rules.new(p)
	for n in range(e.state.units.size()):
		var u=e.state.units[n];u.cell=[28,n];u.strength=0;u.casualties=u.initial_strength;u.ap=0;u.done=true
	for pair in [[0,[2,1]],[1,[2,11]],[10,[2,13]]]:revive(e,pair[0],pair[1])
	e.refresh_support();return e
func revive(e,n,c):
	var u=e.state.units[n];u.cell=c;u.strength=u.initial_strength;u.casualties=0;u.done=false;u.ap=e.max_ap(n);u.morale="stable"
func _initialize():
	var e=fresh()
	check(e.validate(e.state),"new state validates")
	check(e.state.units[0].is_hq and e.state.command_hq.sauer_test_0=="0_0","preferred stable QG")
	check(e.state.units[1].command_ok and e.state.units[1].command_distance==10,"infantry at exactly ten")
	check(e.state.units[10].command_ok and e.state.units[10].command_distance==12,"cavalry at exactly twelve")
	e.state.units[1].cell=[2,12];e.state.units[10].cell=[2,14];e.refresh_support()
	check(not e.state.units[1].command_ok and e.state.units[1].command_reason=="distance","infantry eleven out")
	check(not e.state.units[10].command_ok,"cavalry thirteen out")
	check(e.state.units[1].supply_ok,"supply independent of command distance")
	check(e.state.command_hq.sauer_test_0=="0_0","moving members cannot recenter QG")
	e.state.units[0].morale="shaken";e.refresh_support();check(e.state.units[0].is_hq,"disorganized QG retained")
	e.state.units[0].morale="routed";e.refresh_support()
	check(e.state.command_hq.sauer_test_0=="0_1" and e.state.units[1].is_hq and not e.state.units[0].is_hq,"routed QG transfers")
	e.state.units[0].morale="stable";e.refresh_support();check(e.state.command_hq.sauer_test_0=="0_1","rally does not steal QG back")
	e.state.units[1].casualties=e.state.units[1].initial_strength;e.state.units[1].strength=0;e.state.units[1].ap=0;e.state.units[1].done=true;e.refresh_support()
	check(e.state.command_hq.sauer_test_0=="0_0" and not e.state.units[1].is_hq,"destroyed QG transfers and badge cleared")
	var raw=JSON.stringify(e.pack);var store=Store.new("user://support0820_test.json",raw.sha256_text())
	check(store.save_game(e),"save QG state")
	var restored=Rules.new(e.pack);check(store.load_game(restored) and restored.validate(restored.state) and JSON.parse_string(JSON.stringify(restored.state))==JSON.parse_string(JSON.stringify(e.state)),"exact QG and support save roundtrip")
	var bad=e.state.duplicate(true);bad.command_hq.sauer_test_0="1_0";check(not e.validate(bad),"reject hostile QG in save")
	e=fresh(true);e.river_links[e.river_key(182,212)]=false;e.refresh_support()
	check(not e.state.units[1].supply_ok and e.state.units[1].supply_reason=="river","unbridged river severs supply")
	check(not e.state.units[1].command_ok and e.state.units[1].command_reason=="river","unbridged river severs courier path")
	e.river_links[e.river_key(182,212)]=true;e.refresh_support()
	check(e.state.units[1].supply_ok and e.state.units[1].command_ok,"bridge restores both paths")
	revive(e,4,[2,6]);e.refresh_support()
	check(not e.state.units[1].supply_ok and e.state.units[1].supply_reason=="enemy" and e.state.units[1].command_reason=="enemy","enemy occupying bottleneck cuts both")
	e.state.units[4].cell=[3,6];e.pack.map.tiles[183]="plain";e.refresh_support()
	check(not e.state.units[1].supply_ok,"adjacent enemy ZOC cuts corridor")
	for pair in [[2,[2,6]],[3,[2,7]]]:revive(e,pair[0],pair[1])
	e.refresh_support();check(e.state.units[1].supply_ok,"friendly-held corridor passes enemy ZOC")
	e.state.units[2].strength=0;e.state.units[3].strength=0;e.state.units[4].morale="routed";e.refresh_support()
	check(e.state.units[1].supply_ok,"routed foe has no adjacent ZOC")
	e=fresh();e.state.units[1].cell=[2,8];revive(e,4,[2,5]);e.refresh_support()
	check(e.state.units[1].command_ok and e.state.units[1].supply_ok,"open terrain permits detour")
	e.state.units[1].cell=[2,11];e.refresh_support()
	check(not e.state.units[1].command_ok and e.state.units[1].command_reason=="enemy" and e.state.units[1].supply_ok,"detour beyond command radius still supplies")
	var before=JSON.stringify(e.observation(0,[4]))
	e.state.units[4].is_hq=true;e.state.units[4].hq_id="secret";e.state.units[4].command_reason="river";e.state.units[4].supply_reason="enemy";e.state.command_hq.sauer_test_1="1_3"
	check(before==JSON.stringify(e.observation(0,[4])),"enemy command identity and reasons absent from AI observation")
	e=fresh();e.state.units[1].cell=[2,12];e.state.units[1].morale="shaken";e.state.units[1].cohesion=40;e.refresh_support();e.state.side=1;e.end_side()
	check(e.state.units[1].cohesion==58 and e.state.units[1].ap==16 and e.rally_cost(1)==8,"isolation halves recovery only, rally two PA")
	e=fresh();e.state.units[1].cell=[2,2];e.refresh_support();var snapshot=e.state.duplicate(true)
	check(e.move(1,[62,92])=="moved" and e.undo() and e.state==snapshot,"move and undo preserve command and supply")
	for name in ["legacy0819","legacy_three0819"]:
		var old=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/"+name+".json")))
		check(not old.fixed_hq() and old.pack.rules.support.command_radius==4 and old.validate(old.state),"old rules retained "+name)
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://support0820_test.json"+suffix)
	print("SUPPORT 0820: ",checks-failures,"/",checks)
	quit(1 if failures else 0)
