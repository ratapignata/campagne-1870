extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Support=preload("res://war_engine/core/support.gd")
var checks=0
var failures=0
var qg=-1
var cav=-1
var foot=-1
var enemy=-1
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func fresh():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));var e=Rules.new(p)
	e.pack.rules.fog.enabled=false;e.pack.rules.support.supply_sources=[[[2,6]],[[28,6]]]
	e.river_links.clear();e.road_links.clear();e.bridge_turns.clear()
	for i in range(600):e.pack.map.tiles[i]="plain";e.pack.map.elevations[i]=0
	for n in range(e.state.units.size()):
		var u=e.state.units[n]
		if int(u.side)==0:
			if e.headquarters(n):qg=n
			elif e.cavalry(n):cav=n
			elif not e.artillery(n):foot=n
		elif not e.headquarters(n) and not e.artillery(n) and not e.cavalry(n):enemy=n
		u.strength=0;u.casualties=u.initial_strength;u.pending=false;u.morale="stable";u.prisoners=0;u.ap=0;u.done=true
	for n in [qg,cav,foot]:
		var u=e.state.units[n];u.strength=u.initial_strength;u.casualties=0;u.ap=16;u.done=false;u.command_group="test";u.command_ok=true;u.supply_ok=true
	e.state.units[qg].cell=[2,6];e.state.units[cav].cell=[10,6];e.state.units[foot].cell=[3,6]
	e.state.command_hq={};e.refresh_support();return e
func wall(e,last: int):
	for y in range(last+1):
		var u=e.state.units[enemy].duplicate(true);u.id="wall_"+str(y);u.cell=[7,y];u.strength=u.initial_strength;u.casualties=0;u.ap=16;u.done=false;e.state.units.append(u);e.pack.units.append(u.duplicate(true))
	e.refresh_support()
func _initialize():
	var e=fresh()
	check(e.state.units[cav].command_ok and e.state.units[cav].supply_ok,"unopposed cavalry supplied and commanded")
	e.state.units[cav].cell=[6,6]
	var foe=e.state.units[enemy];foe.cell=[7,6];foe.strength=foe.initial_strength;foe.casualties=0;e.refresh_support()
	check(e.state.units[cav].command_ok and e.state.units[cav].supply_ok,"frontline endpoint retains rear connection")
	e=fresh();wall(e,14)
	var net=Support.strict_networks(e,0)
	check(net.supply.has(e.unit_cell(e.state.units[cav])),"finite barrier physically bypassable")
	check(not e.state.units[cav].supply_ok,"excessive supply detour refused")
	check(not e.state.units[cav].command_ok,"cavalry behind barrier loses command")
	e.end_side();e.end_side()
	check(int(e.state.units[cav].ap)==8 and e.max_ap(cav)==8,"double cut gets two PA next turn")
	check(e.assault_status(cav,e.state.units.size()-1)=="isolated","isolated charges forbidden")
	var snapshot=e.state.duplicate(true);var copy=Rules.new(e.pack);copy.state=JSON.parse_string(JSON.stringify(snapshot));copy.normalize()
	check(copy.validate(copy.state),"isolated save roundtrip valid")
	check(copy.max_ap(cav)==8 and not copy.state.units[cav].supply_ok,"isolation and PA survive reload")
	e.state.units[cav].morale="routed";var men=int(e.state.units[cav].strength);e.refresh_support()
	check(e.alive(cav) and int(e.state.units[cav].prisoners)==0,"routed uncommanded retains a rear corridor")
	var flight=e.retreat(cav);check(flight.route.size()>1,"routed cavalry withdraws legally")
	check(e.state.units[cav].ap==0 and e.state.units[cav].done,"retreated unit inactive")
	var serial=e.state.support_serial;e.refresh_support();check(serial==e.state.support_serial,"no duplicate surrender")
	check(e.validate(e.state),"surrender accounting validates")
	var view=e.observation(0);check(not view.state.has("support_events") and not view.state.has("surrender_serial"),"AI view strips private support history")
	copy=Rules.new(e.pack);copy.state=JSON.parse_string(JSON.stringify(e.state));copy.normalize();check(copy.validate(copy.state) and copy.alive(cav) and copy.state.units[cav].morale=="routed","rout persists after reload")
	e=fresh();e.state.units[cav].cell=[20,6];e.refresh_support()
	check(not e.state.units[cav].command_ok and e.state.units[cav].supply_ok,"distance cuts command only")
	e.end_side();e.end_side();check(e.state.units[cav].ap==12,"command-only cut loses one PA")
	e=fresh();e.state.units[foot].morale="routed";e.refresh_support();check(e.alive(foot),"routed but commanded does not surrender")
	e=fresh();wall(e,19);check(not e.state.units[cav].command_ok and not e.state.units[cav].supply_ok,"sealed wall cuts both connections")
	e.state.units[cav].morale="stable";e.refresh_support();check(e.alive(cav),"isolated orderly unit can still survive")
	e.state.units[foot].cell=[10,5];e.state.units[foot].ammo_level=2;e.state.units[foot].attacked=false;e.refresh_support();e.end_side();e.end_side()
	check(e.state.units[foot].ammo_level==2,"cut infantry cannot refill ammo")
	print("STRICT 0833 ",checks-failures,"/",checks);quit(1 if failures else 0)
