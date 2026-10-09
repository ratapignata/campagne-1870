extends "res://tests/test_strict0833.gd"
func surround(e,n):
	for pos in e.neighbours(e.unit_cell(e.state.units[n])):
		var u=e.state.units[enemy].duplicate(true);u.id="ring_"+str(pos);var c=e.cell(pos);u.cell=[c.x,c.y];u.strength=u.initial_strength;u.casualties=0;u.ap=16;u.done=false
		e.state.units.append(u);e.pack.units.append(u.duplicate(true))
	e.refresh_support()
func boundary(e):e.end_side();e.end_side()
func _initialize():
	var e=fresh()
	check(e.state.units[cav].command_ok and e.state.units[cav].supply_ok,"normal links")
	boundary(e);check(e.state.units[cav].ap==16,"normal four PA")
	e=fresh();e.state.units[cav].cell=[20,6];e.refresh_support();boundary(e)
	check(not e.state.units[cav].command_ok and e.state.units[cav].supply_ok and e.state.units[cav].ap==12,"command only three PA")
	check(e.state.units[cav].isolation_turns==0,"command only no isolation accumulation")
	e.state.units[cav].morale="routed";e.refresh_support()
	check(e.alive(cav),"supplied routed uncommanded survives with corridor")
	var flight=e.retreat(cav);check(flight.route.size()>1 and flight.prisoners==0,"supplied rout retreats")
	check(e.state.units[cav].ap==0 and e.state.units[cav].done,"withdrawal consumes activation")
	e=fresh();e.pack.rules.support.supply_sources=[[[28,6]],[[28,6]]];wall(e,19);boundary(e)
	check(e.state.units[foot].command_ok and not e.state.units[foot].supply_ok,"supply only cut")
	check(e.state.units[foot].ap==16 and e.state.units[foot].isolation_turns==0,"supply only budget unchanged")
	e=fresh();wall(e,19)
	for turn in range(1,5):
		boundary(e)
		check(e.alive(cav) and int(e.state.units[cav].isolation_turns)==turn,"open corridor isolation "+str(turn))
		check(e.max_ap(cav)==8,"double cut maximum two PA "+str(turn))
		if turn==1:check(e.state.units[cav].morale=="stable","first grace")
		elif turn==2:check(e.state.units[cav].morale=="shaken","second disorganisation")
		else:check(e.state.units[cav].morale=="routed","third and later rout")
		check(e.assault_status(cav,e.state.units.size()-1)!="ok","no isolated two PA charge "+str(turn))
	check(e.state.units[cav].cell[1]<6,"retreat progresses toward northern rear")
	check(e.validate(e.state),"four observations valid")
	var copy=Rules.new(e.pack);copy.state=JSON.parse_string(JSON.stringify(e.state));copy.normalize()
	check(copy.validate(copy.state) and copy.alive(cav) and copy.state.units[cav].morale=="routed","save reload routed isolation")
	e=fresh();surround(e,cav)
	for turn in range(3):boundary(e)
	check(not e.alive(cav) and e.state.units[cav].prisoners==e.state.units[cav].initial_strength,"enclosed third observation surrenders")
	check(e.state.surrender_serial==1 and e.state.units[cav].ap==0,"single surrender event and no PA")
	check(e.validate(e.state),"enclosed surrender validates")
	var serial=e.state.surrender_serial;e.refresh_support();check(e.state.surrender_serial==serial,"no repeat surrender")
	e=fresh();wall(e,19);boundary(e);boundary(e);e.state.units[cav].cell=[4,6];e.refresh_support()
	check(e.state.units[cav].isolation_turns==0,"one restored link resets counter")
	boundary(e);check(e.alive(cav) and e.state.units[cav].morale!="routed","restoration before third prevents rout")
	e=fresh();e.state.units[cav].cell=[20,0];e.state.units[cav].morale="routed";e.refresh_support()
	check(e.alive(cav) and e.retreat_route(cav)==[20],"already at own safe rear holds without surrender")
	e=fresh();wall(e,19);e.state.units[cav].morale="routed";e.refresh_support()
	var before=e.state.units[cav].cell.duplicate();flight=e.retreat(cav)
	check(flight.route.size()<=3 and flight.route.size()>1,"at most existing two retreat steps")
	for k in range(1,flight.route.size()):check(e.edge_allowed(cav,flight.route[k-1],flight.route[k]),"each retreat edge legal")
	check(e.unit_at(e.unit_cell(e.state.units[cav]))==cav and before!=e.state.units[cav].cell,"no occupied landing or teleport")
	# Prussian cavalry keeps its actual type and side behind an enemy barrier.
	e=fresh();var pr=-1
	for n in range(e.state.units.size()):
		if int(e.state.units[n].side)==1 and e.cavalry(n):pr=n;break
	var u=e.state.units[pr];u.strength=u.initial_strength;u.casualties=0;u.ap=16;u.done=false;u.pending=false;u.cell=[20,10];u.command_group="pr_test"
	e.pack.rules.support.supply_sources[1]=[[2,6]]
	for y in range(20):
		var guard=e.state.units[foot].duplicate(true);guard.id="fr_barrier_"+str(y);guard.cell=[15,y];guard.command_group="test";e.state.units.append(guard);e.pack.units.append(guard.duplicate(true))
	e.refresh_support();check(not u.command_ok and not u.supply_ok,"Prussian cavalry double cut behind French line")
	for k in range(3):boundary(e)
	check(e.alive(pr) and u.morale=="routed" and u.cell[1]>10,"Prussian cavalry retreats south to its own rear")
	e=fresh();var trapped=cav
	for pos in e.neighbours(e.unit_cell(e.state.units[trapped])):e.pack.map.tiles[pos]="water"
	e.state.units[trapped].morale="routed";e.update_support(0)
	check(e.retreat_route(trapped).is_empty(),"impassable enclosure offers no retreat")
	var result=e.retreat(trapped);check(not e.alive(trapped) and result.prisoners>0,"impassable enclosure surrenders without teleport")
	for arm in ["cavalry","infantry"]:
		e=fresh();var n=cav if arm=="cavalry" else foot
		if arm=="infantry":e.state.units[cav].cell=[20,6]
		e.state.units[n].cell=[10,6];var start=e.unit_cell(e.state.units[n]);var exit=e.index(Vector2i(10,5))
		for pos in e.neighbours(start):e.pack.map.tiles[pos]="water"
		e.pack.map.tiles[exit]="plain";e.river_links[e.river_key(start,exit)]=false;e.state.units[n].morale="routed";e.update_support(0)
		var route=e.retreat_route(n)
		if arm=="cavalry":check(route.is_empty(),"cavalry cannot retreat over an unbridged river")
		else:check(route.size()==2 and route[1]==exit,"infantry may ford but its retreat stops on far bank")
	print("V36 ISOLATION ",checks-failures,"/",checks);quit(1 if failures else 0)
