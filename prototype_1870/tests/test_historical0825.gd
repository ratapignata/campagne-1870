extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func dispatch(e,d):
	var n=e.unit_index(str(d.get("unit","")))
	match d.kind:
		"end":e.end_side();return true
		"move":return e.move(n,d.path) in ["moved","capture","discovered"]
		"fire":return e.fire(n,e.unit_index(d.target)).status=="ok"
		"assault":return e.assault(n,e.unit_index(d.target)).status=="ok"
		"formation":return e.change_formation(n,d.formation)
		"rally":return e.rally(n)
		"rest":return e.rest(n)
		"entrench":return e.entrench(n)
		"deploy","limber":return e.toggle_deployment(n)
	return false
func _initialize():
	var raw=FileAccess.get_file_as_string("res://packs/1870/historical_trial.json");var p=JSON.parse_string(raw);var e=Rules.new(p)
	var seen={};var queue=[0];seen[0]=true
	while not queue.is_empty():
		var a=queue.pop_front()
		for b in e.neighbours(a):
			if e.open_river(a,b) or seen.has(b):continue
			seen[b]=true;queue.append(b)
	check(seen.size()==600,"all terrain connected through the road bridge without fords")
	for edge in p.map.river_edges:check(e.open_river(edge.a,edge.b)==not edge.bridge,"river edge imported")
	for difficulty in ["easy","medium","hard"]:
		for side in [0,1]:
			e=Rules.new(p);e.new_game(side,difficulty);e.state.side=side;e.refresh_intel()
			var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
			var start=Time.get_ticks_msec();var decision=ai.choose(e.observation(side));var elapsed=Time.get_ticks_msec()-start
			check(dispatch(e,decision) and e.validate(e.state),"legal AI action "+difficulty+" camp "+str(side));print(difficulty," camp ",side,": ",elapsed,"ms ",decision.kind)
	e=Rules.new(p)
	for phase in range(36):
		if not e.state.finished:e.end_side()
	check(e.state.finished and e.validate(e.state),"18 turns reach valid result")
	check(e.result_for(0).level!="" and e.result_for(1).level!="","results available for both camps")
	print("HISTORICAL 0825 ",checks-failures,"/",checks);quit(1 if failures else 0)
