extends RefCounted
## Read-only UI classification. Never changes done/AP, never used by the AI.
var usable: Dictionary={}
var exhausted: Dictionary={}
var count=0

func update(source):
	usable.clear();exhausted.clear();count=0
	# Legality queries may fill visibility/path caches. Isolate those writes too.
	# Evaluate the player's remaining budget during the opposing phase without
	# granting AP, changing morale or advancing the live game's turn.
	var e=source.get_script().new(source.pack,source.state)
	e.vision_cache=source.vision_cache.duplicate(true)
	e.road_links=source.road_links.duplicate()
	e.river_links=source.river_links.duplicate()
	e.bridge_turns=source.bridge_turns.duplicate()
	e.state.side=int(e.state.human_side)
	for n in range(e.state.units.size()):
		if not e.alive(n) or int(e.state.units[n].side)!=int(e.state.human_side):continue
		var active=has_action(e,n)
		usable[n]=active;exhausted[n]=not active
		if active and int(source.state.side)==int(source.state.human_side):count+=1

static func has_action(e,n: int) -> bool:
	if not e.can_act(n):return false
	var u=e.state.units[n]
	if e.rally_status(n)=="ok" or (u.morale=="stable" and e.entrench_status(n)=="ok"):return true
	if e.artillery(n) and u.morale!="routed" and int(u.ap)>=int(e.weapon(n).deployment_ap):return true
	for formation in e.pack.rules.get("formations",{}).get("types",{}):
		if e.formation_status(n,str(formation))=="ok":return true
	if has_move(e,n):return true
	if u.morale=="routed":return false
	if bool(e.weapon(n).get("can_fire",true)) and int(u.ap)>=int(e.weapon(n).ap):
		for j in range(e.state.units.size()):
			if e.fire_status(n,j)=="ok":return true
	# Charge/assault keep all existing restrictions, including double isolation.
	if not e.artillery(n) and int(u.ap)>=e.assault_cost(n):
		for j in range(e.state.units.size()):
			if e.assault_status(n,j)=="ok":return true
	# Hold/rest/end-turn, undo and automatic reactions are not active unit orders.
	return false

static func has_move(e,n: int) -> bool:
	if not e.can_act(n):return false
	var u=e.state.units[n]
	if u.deployed or u.get("river_halt",false) or u.morale=="routed":return false
	# Short-circuit the engine's movement graph on its first legal free endpoint.
	# Only friendly occupied cells need further exploration. All edge, river and
	# terrain costs come from the engine, using the same known occupancy policy.
	var start=e.unit_cell(u);var costs={start:0};var open=[start]
	while not open.is_empty():
		var best=0
		for k in range(1,open.size()):
			if costs[open[k]]<costs[open[best]]:best=k
		var current=open[best];open.remove_at(best)
		for next in e.neighbours(current):
			var occupant=e.path_unit_at(next)
			if occupant>=0 and int(e.state.units[occupant].side)!=int(u.side):continue
			var step=e.step_cost(n,current,next);var total=int(costs[current])+step
			if step<0 or total>int(u.ap):continue
			if occupant<0:return true
			if e.open_river(current,next):continue
			if not costs.has(next) or total<int(costs[next]):
				costs[next]=total;open.append(next)
	return false
