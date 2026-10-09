extends SceneTree
const Nav=preload("res://war_engine/core/edge_navigation.gd")
const Rules=preload("res://war_engine/core/engine.gd")
var failures=0
var checks=0
func check(ok: bool,label: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+label)
func _initialize():
	var data=JSON.parse_string(FileAccess.get_file_as_string("res://development/historical05/sector.json"));var nav=Nav.new(data)
	var engine=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json")))
	for tile in data.tiles:
		if not tile.active:continue
		for next in data.adjacency[str(int(tile.id))]:check(engine.distance(int(tile.id),int(next))==1,"sector uses engine hex geometry")
	var all_closed=["C1","C2","C3"]
	var results=[]
	for kind in data.profiles:
		var r=nav.route(kind,int(data.reference_start),int(data.reference_goal))
		check(not r.is_empty(),kind+" can reach west bank")
		check(nav.route(kind,int(data.reference_start),int(data.reference_goal),all_closed).is_empty(),kind+" cannot bypass closed river")
		check(nav.route(kind,-1,0).is_empty(),"invalid input rejected")
		if not r.is_empty():
			for step in r.steps:
				check(not nav.step(kind,step.from,step.to).is_empty(),"every route step legal")
				check(step.ap<=int(data.profiles[kind].ap),"step fits action budget")
		results.append({"kind":kind,"route":r})
	var c1=data.crossings[0];var c2=data.crossings[1];var c3=data.crossings[2]
	check(not nav.step("infantry",int(c1.a),int(c1.b)).is_empty(),"infantry ford")
	check(nav.step("infantry",int(c1.a),int(c1.b)).stop,"ford stops movement")
	check(nav.step("cavalry",int(c1.a),int(c1.b)).is_empty(),"cavalry cannot ford")
	check(nav.step("artillery",int(c2.a),int(c2.b)).is_empty(),"gun cannot use footbridge")
	check(not nav.step("artillery",int(c3.a),int(c3.b)).is_empty(),"gun uses road bridge")
	check(nav.step("artillery",int(c3.b),int(c3.a)).crossing=="C3","bridge is bidirectional")
	for kind in ["cavalry","artillery"]:check(nav.route(kind,int(data.reference_start),int(data.reference_goal),["C3"]).is_empty(),"mounted arms cut off when road bridge closed")
	var route=nav.route("infantry",int(c1.a),int(c1.b));check(route.steps[0].crossing=="C1","direct ford chosen")
	check(nav.route("infantry",int(data.reference_start),int(data.reference_goal),[],[int(data.reference_goal)]).is_empty(),"blocked endpoint not occupied")
	check(nav.route("infantry",int(data.reference_start),int(data.reference_start)).turns==0,"no movement consumes nothing")
	# Cross-and-continue requires a fresh turn, even if physical cost left some AP.
	var endpoint=-1
	for raw in data.adjacency[str(int(c1.b))]:
		if int(raw)!=int(c1.a) and data.tiles[int(raw)].bank==data.tiles[int(c1.b)].bank:endpoint=int(raw);break
	var r=nav.route("infantry",int(c1.a),endpoint,["C2","C3"])
	for i in range(r.get("steps",[]).size()-1):
		if r.steps[i].stop:check(r.steps[i+1].turn>r.steps[i].turn,"hard stop cannot be bypassed in route preview")
	var report={"checks":checks,"failures":failures,"results":results,"godot":Engine.get_version_info().string,"scope":"isolated generic navigation module; no battle or Android test"}
	FileAccess.open("res://development/historical05/test_results.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("HISTORICAL05: %d/%d"%[checks-failures,checks]);quit(1 if failures else 0)
