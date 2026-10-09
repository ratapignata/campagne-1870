extends RefCounted
# Generic terrain/edge route planner. Not yet wired into live battle actions.
# AP use integer quarters. Input contains public terrain and caller-filtered blockers only.
var data: Dictionary
var edges: Dictionary={}
var crossings: Dictionary={}
func _init(input: Dictionary):
	data=input.duplicate(true)
	for id in data.adjacency:
		data.adjacency[id]=data.adjacency[id].map(func(value): return int(value))
	for edge in data.river_edges:edges[key(int(edge.a),int(edge.b))]=edge
	for c in data.crossings:crossings[c.id]=c
func key(a: int,b: int) -> String:return "%d:%d"%[mini(a,b),maxi(a,b)]
func step(kind: String,a: int,b: int,closed: Array=[]) -> Dictionary:
	if not data.profiles.has(kind) or not data.adjacency.has(str(a)) or not b in data.adjacency[str(a)]:return {}
	var profile=data.profiles[kind];var tile=data.tiles[b]
	if not tile.active or not profile.costs.has(tile.terrain):return {}
	var base=int(profile.costs[tile.terrain]);var rise=maxi(0,int(tile.level)-int(data.tiles[a].level))
	if tile.terrain!="road":base+=rise*2
	var edge=edges.get(key(a,b),{})
	if edge.is_empty():return {"ap":base,"stop":false,"crossing":""}
	var candidates=[]
	for id in edge.crossings:
		if id in closed:continue
		var c=crossings[id]
		if c.mode=="bridge":candidates.append({"ap":base,"stop":false,"crossing":id})
		elif kind=="infantry":candidates.append({"ap":base+(8 if c.mode=="ford" else 4),"stop":true,"crossing":id})
	var best={}
	for c in candidates:
		if best.is_empty() or int(c.ap)<int(best.ap):best=c
	return best
func route(kind: String,start: int,goal: int,closed: Array=[],blocked: Array=[]) -> Dictionary:
	if not data.profiles.has(kind) or start<0 or goal<0 or start>=data.tiles.size() or goal>=data.tiles.size():return {}
	if not data.tiles[start].active or not data.tiles[goal].active or goal in blocked:return {}
	if start==goal:return {"path":[start],"steps":[],"elapsed":0,"turns":0,"movement_ap":0}
	var budget=int(data.profiles[kind].ap)
	var costs={start:0};var parents={};var details={};var open=[start]
	while not open.is_empty():
		var best=0
		for k in range(1,open.size()):
			if int(costs[open[k]])<int(costs[open[best]]):best=k
		var current=int(open[best]);open.remove_at(best)
		if current==goal:break
		for raw in data.adjacency[str(current)]:
			var next=int(raw)
			if next in blocked:continue
			var edge=step(kind,current,next,closed)
			if edge.is_empty() or int(edge.ap)>budget:continue
			var depart=int(costs[current]);var spent=depart%budget
			if spent+int(edge.ap)>budget:depart+=budget-spent
			var arrival=depart+int(edge.ap);var movement_turn=depart/budget+1
			if bool(edge.stop) and arrival%budget!=0:arrival+=budget-arrival%budget
			if not costs.has(next) or arrival<int(costs[next]):
				costs[next]=arrival;parents[next]=current;details[next]={"from":current,"to":next,"ap":int(edge.ap),"turn":int(movement_turn),"stop":edge.stop,"crossing":edge.crossing}
				if not next in open:open.append(next)
	if not costs.has(goal):return {}
	var path=[goal];var steps=[];var move_ap=0
	while parents.has(path[0]):
		var s=details[path[0]];steps.push_front(s);move_ap+=int(s.ap);path.push_front(int(parents[path[0]]))
	return {"path":path,"steps":steps,"elapsed":costs[goal],"turns":int(steps[-1].turn),"movement_ap":move_ap}
