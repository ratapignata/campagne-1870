extends RefCounted
# Platform-independent, data-driven rules. Costs are integer quarter action points.
var pack: Dictionary
var state: Dictionary
var previous: Dictionary={}
var width: int
var height: int
var river_links: Dictionary={}
var road_links: Dictionary={}
var bridge_turns: Dictionary={}
var neighbour_cache: Dictionary={}
func _init(data: Dictionary, initial_state: Dictionary={}) -> void:
	pack=data.duplicate(true);width=int(pack.map.width);height=int(pack.map.height)
	for edge in pack.map.get("river_edges",[]):river_links[river_key(int(edge.a),int(edge.b))]=bool(edge.get("bridge",false))
	for edge in pack.map.get("road_edges",[]):road_links[river_key(int(edge[0]),int(edge[1]))]=true
	for edge in pack.map.get("river_edges",[]):
		if edge.has("bridge_from_turn"):bridge_turns[river_key(int(edge.a),int(edge.b))]=int(edge.bridge_from_turn)
	if initial_state.is_empty():new_game()
	else:state=initial_state.duplicate(true)
func new_game() -> void:
	state={"turn":1,"side":0,"units":pack.units.duplicate(true),"scores":[0,0],"owner":-1,"active":-1,"finished":false,"moves":0,"shots":0,"seed":int(randi()%1000000),"events":[],"undo_reason":"none"}
	for u in state.units:
		u.ap=action_budget(u);u.done=false;u.strength=int(u.initial_strength)
		u.deployed=false;u.river_halt=false
	state.owner=int(objective_definitions()[0].get("initial_owner",pack.get("initial_owner",-1)))
	state.objective_owners={}
	for o in objective_definitions():state.objective_owners[str(o.id)]=int(o.get("initial_owner",-1))
	normalize();previous={}
func action_budget(u: Dictionary) -> int:
	var kind=str(pack.weapons[u.weapon].get("unit_type","infantry"))
	return int(pack.get("unit_types",{}).get(kind,{}).get("ap",pack.rules.ap))
func max_ap(n: int) -> int:
	return action_budget(state.units[n])
func normalize() -> void:
	state.undo_reason=str(state.get("undo_reason","none"))
	for f in ["turn","side","owner","active","moves","shots","seed"]:state[f]=int(state[f])
	state.scores=[int(state.scores[0]),int(state.scores[1])]
	if not state.has("objective_owners"):state.objective_owners={}
	for o in objective_definitions():state.objective_owners[str(o.id)]=int(state.objective_owners.get(str(o.id),state.owner if o==objective_definitions()[0] else -1))
	state.objective_owners[str(objective_definitions()[0].id)]=state.owner
	for u in state.units:
		u.river_halt=bool(u.get("river_halt",false))
		for f in ["side","ap","strength","initial_strength"]:u[f]=int(u[f])
		u.cell=[int(u.cell[0]),int(u.cell[1])]
	for event in state.events:
		for f in ["turn","side","shooter","target","loss"]:event[f]=int(event[f])
func index(c: Vector2i) -> int:return c.y*width+c.x if c.x>=0 and c.y>=0 and c.x<width and c.y<height else -1
func cell(i: int) -> Vector2i:return Vector2i(i%width,i/width)
func unit_cell(u: Dictionary) -> int:return index(Vector2i(int(u.cell[0]),int(u.cell[1])))
func alive(n: int) -> bool:return n>=0 and n<state.units.size() and int(state.units[n].strength)>0
func unit_at(i: int) -> int:
	for n in range(state.units.size()):
		if alive(n) and unit_cell(state.units[n])==i:return n
	return -1
func axial(c: Vector2i) -> Vector2i:return Vector2i(c.x,c.y-int((c.x-(c.x&1))/2))
func distance(a: int,b: int) -> int:
	var d=axial(cell(a))-axial(cell(b));return maxi(maxi(absi(d.x),absi(d.y)),absi(d.x+d.y))
func neighbours(i: int) -> Array:
	if neighbour_cache.has(i):return neighbour_cache[i]
	var result=[]
	for dx in range(-1,2):
		for dy in range(-1,2):
			var n=index(cell(i)+Vector2i(dx,dy))
			if n>=0 and distance(i,n)==1:result.append(n)
	neighbour_cache[i]=result
	return result
func cost(i: int) -> int:return int(pack.terrains[pack.map.tiles[i]].cost)
func movement_cost(_n: int,i: int) -> int:return cost(i)
func river_key(a: int,b: int) -> String:return "%d:%d"%[mini(a,b),maxi(a,b)]
func open_river(a: int,b: int) -> bool:
	var k=river_key(a,b)
	return river_links.has(k) and not bool(river_links[k]) and (not bridge_turns.has(k) or int(state.get("turn",1))<int(bridge_turns[k]))
func edge_allowed(n: int,a: int,b: int) -> bool:
	return not open_river(a,b) or (not artillery(n) and not (n>=0 and weapon(n).get("unit_type","")=="cavalry"))
func step_cost(n: int,a: int,b: int) -> int:
	if cost(b)<0 or not edge_allowed(n,a,b):return -1
	var movement=movement_cost(n,b)
	if bool(pack.rules.get("roads_follow_edges",false)) and road_links.has(river_key(a,b)) and not open_river(a,b):movement=road_movement_cost(n)
	return movement+(int(pack.rules.get("river",{}).get("infantry_extra_ap",8)) if open_river(a,b) else 0)
func road_movement_cost(_n: int) -> int:return int(pack.terrains.road.cost)
func path_has_river(path: Array) -> bool:
	for k in range(1,path.size()):
		if open_river(int(path[k-1]),int(path[k])):return true
	return false
func can_act(n: int) -> bool:
	return alive(n) and not state.finished and int(state.units[n].side)==int(state.side) and not state.units[n].done and int(state.units[n].ap)>0
func available_count() -> int:
	var count=0
	for n in range(state.units.size()):
		if can_act(n):count+=1
	return count
func path_unit_at(i: int) -> int:return unit_at(i)
func reach(n: int,unlimited: bool=false) -> Dictionary:
	if not can_act(n) or state.units[n].deployed or state.units[n].get("river_halt",false):return {"costs":{},"parents":{}}
	var start=unit_cell(state.units[n]);var costs={start:0};var parents={};var open=[start]
	var budget=width*height*100 if unlimited else int(state.units[n].ap)
	while not open.is_empty():
		var best=0
		for j in range(1,open.size()):
			if costs[open[j]]<costs[open[best]]:best=j
		var current=open[best];open.remove_at(best)
		for next in neighbours(current):
			var occupied=path_unit_at(next)
			if cost(next)<0 or (occupied>=0 and int(state.units[occupied].side)!=int(state.side)):continue
			var step=step_cost(n,current,next)
			if step<0 or (open_river(current,next) and occupied>=0):continue
			var total=int(costs[current])+step
			# A ford consumes the remaining movement budget, not the remaining action points.
			if not unlimited and open_river(current,next) and total<=budget:total=budget
			if total<=budget and (not costs.has(next) or total<int(costs[next])):
				costs[next]=total;parents[next]=current
				if not open.has(next):open.append(next)
	return {"costs":costs,"parents":parents}
func path_to(n: int,destination: int,unlimited: bool=false) -> Array:
	if not can_act(n) or destination<0 or destination>=width*height or path_unit_at(destination)>=0:return []
	var info=reach(n,unlimited)
	if not info.costs.has(destination):return []
	var path=[destination]
	while info.parents.has(path[0]):path.push_front(info.parents[path[0]])
	return path if path.size()>1 else []
func preview(n: int,destination: int) -> Dictionary:
	var full=path_to(n,destination)
	if full.is_empty():full=path_to(n,destination,true)
	if full.is_empty():return {"full":[],"route":[],"cost":0,"limit":-1}
	var total=0;var last=0
	for k in range(1,full.size()):
		total+=step_cost(n,int(full[k-1]),int(full[k]))
		if total>int(state.units[n].ap):break
		if path_unit_at(full[k])<0:last=k
		if open_river(int(full[k-1]),int(full[k])):break
	var route=full.slice(0,last+1) if last>0 else []
	return {"full":full,"route":route,"cost":path_cost(route,n),"limit":int(route[-1]) if route.size()>1 else -1}
func path_cost(path: Array,n: int=-1) -> int:
	var result=0
	for j in range(1,path.size()):result+=step_cost(n,int(path[j-1]),int(path[j]))
	return result
func move(n: int,path: Array) -> String:
	if not can_act(n) or path.size()<2:return "invalid"
	if state.units[n].deployed:return "deployed"
	if state.units[n].get("river_halt",false):return "river_halt"
	var u=state.units[n]
	if int(path[0])!=unit_cell(u):return "invalid"
	var total=0
	for j in range(1,path.size()):
		var next=int(path[j])
		if next<0 or next>=width*height or distance(int(path[j-1]),next)!=1 or cost(next)<0:return "invalid"
		var occupied=unit_at(next)
		if occupied>=0 and (int(state.units[occupied].side)!=int(state.side) or j==path.size()-1):return "occupied"
		var step=step_cost(n,int(path[j-1]),next)
		if step<0 or (open_river(int(path[j-1]),next) and j<path.size()-1):return "river"
		total+=step
	if total>int(u.ap):return "no_ap"
	previous=state.duplicate(true);state.undo_reason="available";state.active=n
	var dest=cell(int(path[-1]));u.cell=[dest.x,dest.y];u.ap=int(u.ap)-total
	u.river_halt=path_has_river(path)
	state.moves+=1
	if u.ap==0:u.done=true;state.active=-1
	if capture_objective(int(path[-1]),int(state.side)):
		previous={};state.undo_reason="capture";return "capture"
	return "moved"
# Single-objective packs remain valid. The legacy owner mirrors the first objective.
func objective_definitions() -> Array:
	if state.get("objective_layout","")=="v4312" and pack.has("previous_objectives"):return pack.previous_objectives
	if pack.has("objectives") and not pack.objectives.is_empty():return pack.objectives
	var legacy=pack.objective.duplicate(true);legacy.id="primary"
	return [legacy]
func objective_cell(o: Dictionary) -> int:return index(Vector2i(int(o.cell[0]),int(o.cell[1])))
func objective() -> int:return objective_cell(objective_definitions()[0])
func objective_at(pos: int) -> Dictionary:
	for o in objective_definitions():
		if objective_cell(o)==pos:return o
	return {}
func objective_owner(o: Dictionary) -> int:
	if o==objective_definitions()[0]:return int(state.owner)
	return int(state.get("objective_owners",{}).get(str(o.id),-1))
func capture_objective(pos: int,side: int) -> bool:
	var o=objective_at(pos)
	if o.is_empty() or not side in [0,1] or objective_owner(o)==side:return false
	var n=unit_at(pos)
	if n<0 or int(state.units[n].side)!=side or state.units[n].get("morale","stable")=="routed":return false
	state.objective_owners[str(o.id)]=side
	if pos==objective():state.owner=side
	return true
func objective_value_total() -> float:
	var total=0.0
	for o in objective_definitions():total+=float(o.points)
	return total
func controlled_value(side: int) -> float:
	var total=0.0
	for o in objective_definitions():
		if objective_owner(o)==side:total+=float(o.points)
	return total
func undo_status() -> String:
	if state.finished:return "finished"
	if not previous.is_empty():return "ok"
	var reason=str(state.get("undo_reason","none"))
	return "none" if reason=="available" else reason
func undo() -> bool:
	if previous.is_empty() or state.finished:return false
	state=previous.duplicate(true);normalize();previous={};return true
func hold(n: int) -> bool:
	if not can_act(n):return false
	state.units[n].done=true
	if int(state.active)==n:state.active=-1
	previous={};state.undo_reason="rest";return true
func end_side() -> void:
	if state.finished:return
	previous={};state.undo_reason="turn";state.active=-1
	state.objective_owners[str(objective_definitions()[0].id)]=int(state.owner)
	if int(state.side)==1:
		for o in objective_definitions():
			var occupant=unit_at(objective_cell(o))
			if occupant>=0:capture_objective(objective_cell(o),int(state.units[occupant].side))
			var owner=objective_owner(o)
			if owner>=0:state.scores[owner]+=int(o.points)
		if int(state.turn)>=int(pack.rules.turns):state.finished=true;return
		state.turn+=1
	state.side=1-int(state.side)
	for u in state.units:
		if int(u.side)==int(state.side):u.ap=action_budget(u) if int(u.strength)>0 and not u.get("pending",false) else 0;u.done=int(u.strength)<=0
func cube(i: int) -> Vector3:
	var a=axial(cell(i));return Vector3(a.x,-a.x-a.y,a.y)
func round_hex(v: Vector3) -> int:
	var x=roundi(v.x);var y=roundi(v.y);var z=roundi(v.z)
	var dx=absf(x-v.x);var dy=absf(y-v.y);var dz=absf(z-v.z)
	if dx>dy and dx>dz:x=-y-z
	elif dy>dz:y=-x-z
	else:z=-x-y
	return index(Vector2i(x,z+int((x-(x&1))/2)))
func elevation(i: int) -> float:
	return float(pack.map.elevations[i]) if pack.map.has("elevations") else float(pack.terrains[pack.map.tiles[i]].get("elevation",0.0))
func line_unit_at(i: int,_shooter: int) -> int:return unit_at(i)
func terrain_obstacle_status(i: int,sight: float) -> String:
	# Shared geometric test for fire and reconnaissance. A higher hex is only
	# blocking when its surface or cover actually intersects the sight ray.
	var terrain=pack.terrains[pack.map.tiles[i]]
	if elevation(i)>=sight-0.00001:return "blocked_terrain"
	var obstacle=float(terrain.get("obstacle_height",1.0 if terrain.blocks_fire else 0.0))
	return "blocked_cover" if obstacle>0 and elevation(i)+obstacle>=sight-0.00001 else "ok"
func line_status(a: int,b: int) -> String:
	if a<0 or b<0 or a>=width*height or b>=width*height:return "blocked"
	var cfg=pack.rules.get("line_of_fire",{})
	var steps=distance(a,b);var shooter=unit_at(a)
	var eye=float(cfg.get("sight_height",0.4))
	var start_height=elevation(a)+eye;var end_height=elevation(b)+eye
	var can_overhead=artillery(shooter) and bool(cfg.get("elevated_artillery_overhead",false))
	for sign_value in [-1.0,1.0]:
		var offset=Vector3(0.00001,0.00001,-0.00002)*sign_value
		for k in range(1,steps):
			var i=round_hex((cube(a)+offset).lerp(cube(b)+offset,float(k)/steps))
			if i<0:return "blocked"
			var sight=lerpf(start_height,end_height,float(k)/steps)
			var terrain_status=terrain_obstacle_status(i,sight)
			if terrain_status!="ok":return terrain_status
			var occupant=line_unit_at(i,shooter)
			if occupant<0:continue
			var friendly=shooter>=0 and int(state.units[occupant].side)==int(state.units[shooter].side)
			var safe_height=elevation(i)+float(cfg.get("unit_height",0.4))+float(cfg.get("friendly_clearance",0.2))
			if friendly and can_overhead and elevation(a)>elevation(i) and sight>safe_height+0.00001:continue
			return "blocked_friendly" if friendly else "blocked_unit"
	return "ok"
func line_clear(a: int,b: int) -> bool:return line_status(a,b)=="ok"
func weapon(n: int) -> Dictionary:return pack.weapons[state.units[n].weapon]
func artillery(n: int) -> bool:
	return n>=0 and n<state.units.size() and bool(weapon(n).get("requires_deployment",false))
func toggle_deployment(n: int) -> bool:
	if not can_act(n) or not artillery(n):return false
	var u=state.units[n];var amount=int(weapon(n).deployment_ap)
	if int(u.ap)<amount:return false
	u.deployed=not u.deployed;u.ap=int(u.ap)-amount;u.done=u.ap<=0
	state.active=n if not u.done else -1;previous={};state.undo_reason="deployment"
	return true
# Shared legality for an empty destination or an actual target. No state mutation.
func fire_cell_status(shooter: int,destination: int) -> String:
	if not can_act(shooter) or destination<0 or destination>=width*height:return "invalid"
	var a=unit_cell(state.units[shooter])
	if a==destination:return "invalid"
	var w=weapon(shooter)
	if artillery(shooter) and not state.units[shooter].deployed:return "limbered"
	if int(state.units[shooter].ap)<int(w.ap):return "no_ap"
	if distance(a,destination)>int(w.range):return "range"
	return line_status(a,destination)
func fire_status(shooter: int,target: int) -> String:
	if not can_act(shooter) or not alive(target) or shooter==target:return "invalid"
	if int(state.units[shooter].side)==int(state.units[target].side):return "friendly"
	return fire_cell_status(shooter,unit_cell(state.units[target]))
func fire(shooter: int,target: int) -> Dictionary:
	var status=fire_status(shooter,target)
	if status!="ok":return {"status":status}
	var a=state.units[shooter];var b=state.units[target];var w=weapon(shooter)
	var d=distance(unit_cell(a),unit_cell(b));var terrain=pack.terrains[pack.map.tiles[unit_cell(b)]]
	var random=RandomNumberGenerator.new();random.seed=int(state.seed)+int(state.shots)*7919
	var roll=random.randf_range(1.0-float(w.variance),1.0+float(w.variance))
	var loss=mini(int(b.strength),maxi(1,roundi(float(w.base_losses)*float(a.strength)/float(a.initial_strength)*float(w.distance_factors[d-1])*float(terrain.fire_received)*roll)))
	a.ap=int(a.ap)-int(w.ap);a.done=a.ap<=0;b.strength=int(b.strength)-loss
	if b.strength<=0:b.done=true;b.ap=0
	state.shots+=1;state.active=shooter if not a.done else -1;previous={}
	var event={"turn":state.turn,"side":state.side,"shooter":shooter,"target":target,"loss":loss,"eliminated":int(b.strength)<=0}
	state.events.append(event)
	return {"status":"ok","event":event}
func losses(side: int) -> int:
	var result=0
	for u in state.units:
		if int(u.side)==side:result+=int(u.initial_strength)-int(u.strength)
	return result
static func whole_number(value) -> bool:
	# JSON represents integral numbers as floats. Reject coercible strings/bools.
	return (value is int or value is float) and is_finite(float(value)) and float(value)==floor(float(value))
func validate(s: Dictionary) -> bool:
	for key in ["turn","side","units","scores","owner","active","finished","moves","shots","seed","events"]:
		if not s.has(key):return false
	if not s.units is Array or not s.events is Array or not s.scores is Array or not s.finished is bool:return false
	for key in ["turn","side","owner","active","moves","shots","seed"]:
		if not whole_number(s[key]):return false
	if not whole_number(s.get("assaults",0)):return false
	var definitions=objective_definitions()
	if definitions.size()>1 and not s.get("objective_owners",null) is Dictionary:return false
	if s.has("objective_owners"):
		if not s.objective_owners is Dictionary or s.objective_owners.size()!=definitions.size():return false
		for o in definitions:
			var owner=s.objective_owners.get(str(o.id),null)
			if not owner is int and not owner is float:return false
			if float(owner)!=int(owner) or not int(owner) in [-1,0,1]:return false
		if int(s.objective_owners[str(definitions[0].id)])!=int(s.owner):return false
	if not s.units is Array or s.units.size()!=pack.units.size():return false
	if not s.scores is Array or s.scores.size()!=2 or not s.events is Array:return false
	var score_sum=0.0
	for score in s.scores:
		if not score is int and not score is float:return false
		if not is_finite(float(score)) or float(score)<0 or float(score)!=floor(float(score)):return false
		score_sum+=float(score)
	if score_sum>float(pack.rules.turns)*objective_value_total():return false
	if int(s.turn)<1 or int(s.turn)>int(pack.rules.turns) or not int(s.side) in [0,1]:return false
	if not int(s.owner) in [-1,0,1] or int(s.active)<-1 or int(s.active)>=s.units.size():return false
	if int(s.shots)<0 or int(s.shots)>pack.units.size()*int(pack.rules.turns)*int(pack.rules.ap):return false
	if s.events.size()!=int(s.shots)+int(s.get("assaults",0)):return false
	for event in s.events:
		if not event is Dictionary:return false
		for key in ["turn","side","shooter","target","loss","eliminated"]:
			if not event.has(key):return false
		for key in ["turn","side","shooter","target","loss"]:
			if not whole_number(event[key]):return false
		if int(event.shooter)<0 or int(event.shooter)>=s.units.size() or int(event.target)<0 or int(event.target)>=s.units.size():return false
	var occupied={}
	for j in range(s.units.size()):
		var u=s.units[j]
		if not u is Dictionary:return false
		for key in ["id","side","cell","ap","done","name_key","strength","initial_strength","weapon","deployed"]:
			if not u.has(key):return false
		for key in ["side","ap","strength","initial_strength"]:
			if not whole_number(u[key]):return false
		if not u.done is bool:return false
		if not u.deployed is bool or (u.deployed and not bool(pack.weapons[pack.units[j].weapon].get("requires_deployment",false))):return false
		if u.id!=pack.units[j].id or int(u.side)!=int(pack.units[j].side) or u.weapon!=pack.units[j].weapon:return false
		if int(u.initial_strength)!=int(pack.units[j].initial_strength) or int(u.strength)<0 or int(u.strength)>int(u.initial_strength):return false
		if not u.cell is Array or u.cell.size()!=2:return false
		if not whole_number(u.cell[0]) or not whole_number(u.cell[1]):return false
		var pos=unit_cell(u)
		if pos<0 or cost(pos)<0:return false
		if int(u.strength)>0:
			if occupied.has(pos):return false
			occupied[pos]=true
		if int(u.ap)<0 or int(u.ap)>action_budget(u):return false
	return true
