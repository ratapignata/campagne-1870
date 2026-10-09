extends RefCounted
# Terrain-only observation: troops do not magically block the observer's view.
static func clear(e,a: int,b: int) -> bool:
	var distance=e.distance(a,b)
	if distance<=1:return true
	var eye=float(e.pack.rules.get("line_of_fire",{}).get("sight_height",0.4))
	var start=e.elevation(a)+eye;var end=e.elevation(b)+eye
	for sign_value in [-1.0,1.0]:
		var offset=Vector3(0.00001,0.00001,-0.00002)*sign_value
		for k in range(1,distance):
			var i=e.round_hex((e.cube(a)+offset).lerp(e.cube(b)+offset,float(k)/distance))
			if i<0:return false
			if e.terrain_obstacle_status(i,lerpf(start,end,float(k)/distance))!="ok":return false
	return true
static func compute(e,side: int) -> Dictionary:
	var cfg=e.pack.rules.fog;var cells={};var searched={};var levels={};var adjacent={}
	for n in range(e.state.units.size()):
		if not e.alive(n) or int(e.state.units[n].side)!=side:continue
		var start=e.unit_cell(e.state.units[n]);var reach=int(cfg.cavalry_range if e.cavalry(n) else cfg.artillery_range if e.artillery(n) else cfg.infantry_range)
		if e.elevation(start)>0:reach+=int(cfg.height_bonus)
		for i in range(e.width*e.height):
			var d=e.distance(start,i)
			if d<=reach and clear(e,start,i):
				cells[str(i)]=true
				if not bool(e.pack.terrains[e.pack.map.tiles[i]].get("concealment",e.pack.map.tiles[i] in ["forest","village"])) or d<=int(cfg.concealment_range):searched[str(i)]=true
		for j in range(e.state.units.size()):
			if not e.alive(j) or int(e.state.units[j].side)==side:continue
			var pos=e.unit_cell(e.state.units[j]);var d=e.distance(start,pos);var cover=bool(e.pack.terrains[e.pack.map.tiles[pos]].get("concealment",e.pack.map.tiles[pos] in ["forest","village"]))
			if d>reach or (cover and d>int(cfg.concealment_range)) or not clear(e,start,pos):continue
			var level=2 if d<=int(cfg.identify_cover_range if cover else cfg.identify_range) else 1
			levels[str(j)]=maxi(level,int(levels.get(str(j),0)))
			if d==1 and bool(cfg.get("exact_adjacent",false)):adjacent[str(j)]=true
	var observed=levels.duplicate()
	for j in e.state.get("revealed",[[],[]])[side]:
		if e.alive(int(j)):levels[str(int(j))]=maxi(1,int(levels.get(str(int(j)),0)))
	return {"cells":cells,"searched":searched,"levels":levels,"observed":observed,"adjacent":adjacent}
static func report(e,n: int,level: int,exact: bool=false) -> Dictionary:
	var u=e.state.units[n];var cfg=e.pack.rules.fog
	var step=int(cfg.identified_estimate_step if level==2 else cfg.estimate_step)
	var low=maxi(1,floori(float(u.strength-1)/step)*step);var high=(floori(float(u.strength-1)/step)+1)*step
	var result={"cell":u.cell.duplicate(),"type":"cavalry" if e.cavalry(n) else "artillery" if e.artillery(n) else "infantry","level":level,"low":low,"high":high,"name_key":u.name_key if level==2 else "fog_cavalry" if e.cavalry(n) else "fog_artillery" if e.artillery(n) else "fog_infantry","number":int(u.number) if level==2 else 0,"morale":u.morale if level==2 else "unknown","entrenched":bool(u.entrenched) if level==2 else false,"formation":u.formation if level==2 else "unknown","deployed":bool(u.deployed) if level==2 else false,"turn":int(e.state.turn)}
	if level==2 and e.headquarters(n):result.type="hq"
	if exact:
		result.exact_strength=int(u.strength)
		result.exact_power=maxi(1,ceili(float(u.strength)/float(u.initial_strength)*10))
	return result
