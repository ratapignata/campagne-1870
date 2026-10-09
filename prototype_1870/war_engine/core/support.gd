extends RefCounted
# Never export
# these paths, enemy anchors or blockers to the other player's observation.
static func flood(e, seeds: Array, blocked: Dictionary, budget: int=10000, bridges_only: bool=false) -> Dictionary:
	var reached={};var queue=[];var head=0
	for pos in seeds:
		if pos>=0 and e.cost(pos)>=0 and not blocked.has(pos):reached[pos]=0;queue.append(pos)
	while head<queue.size():
		var pos=int(queue[head]);head+=1
		if int(reached[pos])>=budget:continue
		for next in e.neighbours(pos):
			if reached.has(next) or blocked.has(next) or e.cost(next)<0:continue
			if bridges_only and e.open_river(pos,next):continue
			reached[next]=int(reached[pos])+1;queue.append(next)
	return reached

static func assess_side(e, side: int) -> Dictionary:
	if e.pack.rules.support.get("strict_links",false):
		var net=strict_networks(e,side);var reports={}
		for n in range(e.state.units.size()):
			if e.alive(n) and int(e.state.units[n].side)==side:reports[n]=strict_report(e,n,net)
		return reports
	var cfg=e.pack.rules.support;var occupied={};var blocked={};var members={}
	for n in range(e.state.units.size()):
		if not e.alive(n):continue
		var u=e.state.units[n];var pos=e.unit_cell(u);occupied[pos]=n
		if int(u.side)==side:
			var group=str(u.get("command_group",str(side)))
			if not members.has(group):members[group]=[]
			members[group].append(n)
	for n in range(e.state.units.size()):
		if not e.alive(n) or int(e.state.units[n].side)==side:continue
		var pos=e.unit_cell(e.state.units[n]);blocked[pos]=true
		if e.state.units[n].morale=="routed":continue
		for next in e.neighbours(pos):
			# Friendly occupied cells can keep a defended corridor open.
			if not occupied.has(next) or int(e.state.units[occupied[next]].side)!=side:blocked[next]=true
	var seeds=[]
	for c in cfg.supply_sources[side]:seeds.append(e.index(Vector2i(int(c[0]),int(c[1]))))
	var supplied=flood(e,seeds,blocked,10000,bool(cfg.get("supply_requires_bridge",false)))
	var supply_clear=flood(e,seeds,{},10000,bool(cfg.get("supply_requires_bridge",false))) if cfg.get("fixed_hq",false) else {}
	var rear=[]
	if cfg.has("rear_rows"):
		for col in range(e.width):rear.append(e.index(Vector2i(col,int(cfg.rear_rows[side]))))
	else:
		var edge=int(cfg.rear_columns[side])
		for row in range(e.height):rear.append(e.index(Vector2i(edge,row)))
	var escape=flood(e,rear,blocked);var anchors={};var commands={};var clear_commands={};var leaders={}
	for group in members:
		var candidates=[]
		for n in members[group]:
			if not e.cavalry(n) and not e.artillery(n) and e.state.units[n].morale!="routed":candidates.append(n)
		if candidates.is_empty():
			for n in members[group]:
				if e.state.units[n].morale!="routed":candidates.append(n)
		var chosen=-1;var best=-INF
		if cfg.get("fixed_hq",false):
			var leader_id=str(e.state.get("command_hq",{}).get(group,""))
			chosen=e.unit_index(leader_id)
			if chosen<0 or not e.alive(chosen) or e.state.units[chosen].morale=="routed" or int(e.state.units[chosen].side)!=side:chosen=-1
		else:
			for n in candidates:
				var score=0.0
				for j in candidates:
					var d=e.distance(e.unit_cell(e.state.units[n]),e.unit_cell(e.state.units[j]))
					score+=100.0 if d<=int(cfg.command_radius) else 0.0;score-=d
				if score>best:best=score;chosen=n
		if chosen>=0:
			leaders[group]=chosen;anchors[group]=e.unit_cell(e.state.units[chosen])
			commands[group]=flood(e,[anchors[group]],blocked,int(cfg.cavalry_command_radius),bool(cfg.get("command_requires_bridge",false)))
			if cfg.get("fixed_hq",false):clear_commands[group]=flood(e,[anchors[group]],{},10000,bool(cfg.get("command_requires_bridge",false)))

	var result={}
	for group in members:
		for n in members[group]:
			var pos=e.unit_cell(e.state.units[n]);var radius=int(cfg.cavalry_command_radius if e.cavalry(n) else cfg.command_radius)
			result[n]={"supply_ok":supplied.has(pos),"command_ok":commands.has(group) and int(commands[group].get(pos,10000))<=radius,"encircled":not escape.has(pos)}
			if cfg.get("fixed_hq",false):
				var report=result[n]
				report.is_hq=leaders.get(group,-1)==n
				report.hq_id=str(e.state.units[leaders[group]].id) if leaders.has(group) else ""
				report.command_distance=int(commands.get(group,{}).get(pos,-1))
				report.command_reason="ok" if report.command_ok else "no_hq" if not leaders.has(group) else "river" if not clear_commands[group].has(pos) else "distance" if int(clear_commands[group][pos])>radius else "enemy"
				report.supply_reason="ok" if report.supply_ok else "enemy" if supply_clear.has(pos) else "river"
	return result

# Strict networks never relay a connection through a contested friendly unit.
# A served frontline unit may be the final step from a safe neighbouring cell.
static func terminal_distance(e, pos: int, field: Dictionary, bridges_only: bool) -> int:
	if field.has(pos):return int(field[pos])
	if pos<0 or e.cost(pos)<0:return 10000
	var best=10000
	for next in e.neighbours(pos):
		if bridges_only and e.open_river(pos,next):continue
		if field.has(next):best=mini(best,int(field[next])+1)
	return best

static func strict_networks(e, side: int) -> Dictionary:
	var cfg=e.pack.rules.support;var blocked={};var enemy_cells={};var leaders={}
	for n in range(e.state.units.size()):
		if not e.alive(n) or int(e.state.units[n].side)==side:continue
		var pos=e.unit_cell(e.state.units[n]);enemy_cells[pos]=true;blocked[pos]=true
		if e.state.units[n].morale!="routed":
			for next in e.neighbours(pos):blocked[next]=true
	var supply_seeds=[]
	for c in cfg.supply_sources[side]:supply_seeds.append(e.index(Vector2i(int(c[0]),int(c[1]))))
	var bridge_supply=bool(cfg.get("supply_requires_bridge",false));var bridge_command=bool(cfg.get("command_requires_bridge",false))
	var net={"supply":flood(e,supply_seeds,blocked,10000,bridge_supply),"supply_clear":flood(e,supply_seeds,{},10000,bridge_supply),"commands":{},"commands_clear":{},"leaders":leaders,"enemy_cells":enemy_cells}
	for group in e.state.get("command_hq",{}):
		var n=e.unit_index(str(e.state.command_hq[group]))
		if not e.alive(n) or int(e.state.units[n].side)!=side or e.state.units[n].morale=="routed":continue
		leaders[group]=n
		var seed=e.unit_cell(e.state.units[n]);var command_blocks=blocked.duplicate();command_blocks.erase(seed)
		net.commands[group]=flood(e,[seed],command_blocks,int(cfg.cavalry_command_radius),bridge_command)
		net.commands_clear[group]=flood(e,[seed],{},10000,bridge_command)
	var rear=[]
	if cfg.has("rear_rows"):
		for col in range(e.width):rear.append(e.index(Vector2i(col,int(cfg.rear_rows[side]))))
	else:
		for row in range(e.height):rear.append(e.index(Vector2i(int(cfg.rear_columns[side]),row)))
	net.escape=flood(e,rear,blocked)
	return net

static func strict_report(e,n: int,net: Dictionary,pos: int=-1) -> Dictionary:
	var u=e.state.units[n];var cfg=e.pack.rules.support
	if pos<0:pos=e.unit_cell(u)
	var group=str(u.get("command_group",str(u.side)));var leader=int(net.leaders.get(group,-1))
	var bridge_supply=bool(cfg.get("supply_requires_bridge",false));var bridge_command=bool(cfg.get("command_requires_bridge",false))
	var sd=terminal_distance(e,pos,net.supply,bridge_supply);var sc=int(net.supply_clear.get(pos,10000))
	var cd=terminal_distance(e,pos,net.commands.get(group,{}),bridge_command);var cc=int(net.commands_clear.get(group,{}).get(pos,10000))
	var radius=int(cfg.cavalry_command_radius if e.cavalry(n) else cfg.command_radius)
	var supply=sd<10000 and sd<=sc+int(cfg.get("supply_detour",3))
	var command=leader>=0 and cd<=radius and cd<=cc+int(cfg.get("command_detour",2))
	if net.enemy_cells.has(pos):supply=false;command=false
	return {"supply_ok":supply,"command_ok":command,"encircled":terminal_distance(e,pos,net.escape,false)>=10000,"is_hq":leader==n,"hq_id":str(e.state.units[leader].id) if leader>=0 else "","command_distance":cd if cd<10000 else -1,"command_reason":"ok" if command else "no_hq" if leader<0 else "river" if cc>=10000 else "distance" if cc>radius else "enemy","supply_reason":"ok" if supply else "river" if sc>=10000 else "detour" if sd<10000 else "enemy"}
