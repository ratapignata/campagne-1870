extends RefCounted
# Public geometry only; never receives units, visibility or combat state.
static func river_curve(view) -> Curve2D:
	var graph={};var points={}
	for edge in view.engine.pack.map.get("river_edges",[]):
		var a=view.world(int(edge.a));var b=view.world(int(edge.b));var normal=(b-a).normalized()
		var tangent=Vector2(-normal.y,normal.x)*view.R/2;var middle=(a+b)/2
		var ends=[middle-tangent,middle+tangent];var keys=[]
		for p in ends:
			var key=Vector2i(roundi(p.x*1000),roundi(p.y*1000));keys.append(key);points[key]=p
			if not graph.has(key):graph[key]=[]
		graph[keys[0]].append(keys[1]);graph[keys[1]].append(keys[0])
	var curve=Curve2D.new();var start=null
	for key in graph:
		if graph[key].size()==1 and (start==null or points[key].x<points[start].x):start=key
	if start==null:return curve
	var path=[];var visited={};var current=start
	while not visited.has(current):
		visited[current]=true;path.append(points[current]);var next=null
		for key in graph[current]:
			if not visited.has(key):next=key;break
		if next==null:break
		current=next
	if visited.size()!=graph.size():return Curve2D.new()
	for k in range(path.size()):
		var tangent=(path[mini(k+1,path.size()-1)]-path[maxi(k-1,0)])/6.0
		curve.add_point(path[k],-tangent if k>0 else Vector2.ZERO,tangent if k<path.size()-1 else Vector2.ZERO)
	return curve
static func name_center(view,curve: Curve2D) -> float:
	var length=curve.get_baked_length();var best=length/2;var clearance=-INF
	for offset in range(120,int(length)-120,17):
		var pos=curve.sample_baked(offset);var score=INF
		for label in view.engine.pack.map.get("labels",[]):
			var cell=Vector2i(int(label.cell[0]),int(label.cell[1]));score=minf(score,pos.distance_to(view.world(view.engine.index(cell)))-100)
		for goal in view.engine.objective_definitions():score=minf(score,pos.distance_to(view.world(view.engine.objective_cell(goal)))-100)
		for edge in view.engine.pack.map.get("road_edges",[]):score=minf(score,pos.distance_to((view.world(int(edge[0]))+view.world(int(edge[1])))/2)-45)
		for edge in view.engine.pack.map.get("river_edges",[]):
			if bool(edge.bridge) or edge.has("bridge_from_turn"):score=minf(score,pos.distance_to((view.world(int(edge.a))+view.world(int(edge.b)))/2)-100)
		if score>clearance:clearance=score;best=offset
	return best
static func reichshoffen_offset(radius: float) -> Vector2:
	return Vector2(0,sqrt(3.0)*radius)
