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

static func name_centers(view,curve: Curve2D,text_width: float) -> Array:
	# Pick the left/right ends of the visible river, not off-screen map ends.
	var candidates=[];var margin=text_width/2+12.0/view.zoom
	var rect=Rect2(Vector2(12,12),view.size-Vector2(24,24))
	for offset in range(int(margin),int(curve.get_baked_length()-margin),12):
		var pos=curve.sample_baked(offset,true)
		var screen=(pos-view.focus)*view.zoom+view.size/2
		if rect.has_point(screen) and screen.x>text_width*view.zoom/2+34 and screen.x<view.size.x-text_width*view.zoom/2-34 and screen.y>clampi(int(23*view.zoom),20,38)+24 and screen.y<view.size.y-55:
			candidates.append(float(offset))
	if candidates.is_empty():return []
	var result=[]
	for part in [0,1]:
		var best=-1.0;var best_score=-INF
		for offset in candidates:
			var fraction=(offset-candidates[0])/maxf(1,candidates[-1]-candidates[0])
			if (part==0 and fraction>0.35) or (part==1 and fraction<0.65):continue
			if not result.is_empty() and absf(offset-result[0])<text_width+30/view.zoom:continue
			var pos=curve.sample_baked(offset,true);var clearance=200.0
			for goal in view.engine.objective_definitions():clearance=minf(clearance,pos.distance_to(view.world(view.engine.objective_cell(goal)))-70)
			for edge in view.engine.pack.map.get("river_edges",[]):
				if bool(edge.bridge) or edge.has("bridge_from_turn"):clearance=minf(clearance,pos.distance_to((view.world(int(edge.a))+view.world(int(edge.b)))/2)-65)
			for label in view.engine.pack.map.get("labels",[]):
				clearance=minf(clearance,pos.distance_to(view.world(view.engine.index(Vector2i(int(label.cell[0]),int(label.cell[1])))))-75)
			# Only visible counters influence layout, never undiscovered enemies.
			for n in range(view.engine.state.units.size()):
				if view.engine.alive(n) and view.engine.visible_to(int(view.engine.state.human_side),n):
					clearance=minf(clearance,pos.distance_to(view.world(view.engine.unit_cell(view.engine.state.units[n])))-55-text_width/2)
			var score=clearance-absf(fraction-(0.15 if part==0 else 0.85))*30
			if score>best_score:best_score=score;best=offset
		if best>=0:result.append(best)
	return result

static func label_curve(river: Curve2D,center: float,width: float,zoom: float) -> Curve2D:
	# Smooth only the lettering baseline, keeping the real river and terrain intact.
	# Arc-length placement on this baseline prevents letters bunching at hex corners.
	var points=[];var span=width*0.8+35/zoom;var length=river.get_baked_length()
	for k in range(9):
		var offset=center-span+2*span*k/8.0;var point=Vector2.ZERO
		for delta in [-2,-1,0,1,2]:point+=river.sample_baked(clampf(offset+delta*20/zoom,0,length),true)/5.0
		points.append(point)
	var curve=Curve2D.new()
	for k in range(points.size()):
		var tangent=(points[mini(k+1,points.size()-1)]-points[maxi(k-1,0)])/6.0
		curve.add_point(points[k],-tangent if k>0 else Vector2.ZERO,tangent if k<points.size()-1 else Vector2.ZERO)
	return curve
