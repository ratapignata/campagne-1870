extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Brain=preload("res://war_engine/ai/tactical_ai.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func scenario(data):
	var p=data.duplicate(true);p.map.tiles.fill("plain");var e=Rules.new(p)
	for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,18]
	e.state.units[0].cell=[5,5];e.state.units[4].cell=[5,6];e.state.seed=123
	return e
func visible(e) -> Array:
	var result=[]
	for n in range(e.state.units.size()):
		if e.alive(n) and int(e.state.units[n].side)!=int(e.state.side):result.append(n)
	return result
func apply(e,d) -> bool:
	if d.kind=="end":e.end_side();return true
	var n=e.unit_index(d.unit)
	match d.kind:
		"fire":return e.fire(n,e.unit_index(d.target)).status=="ok"
		"assault":return e.assault(n,e.unit_index(d.target)).status=="ok"
		"move":return e.move(n,d.path) in ["moved","capture"]
		"rally":return e.rally(n)
		"formation":return e.change_formation(n,d.formation)
		"entrench":return e.entrench(n)
		"deploy","limber":return e.toggle_deployment(n)
	return false
func _initialize():
	var data=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/prototype08.json"));var e=scenario(data)
	check(e.state.units[4].morale=="stable","initial stable")
	var shot=e.fire(0,4)
	check(shot.status=="ok" and e.state.units[4].morale=="stable","one ordinary close volley no longer shakes full unit")
	check(e.losses(1)==shot.event.loss and e.prisoners(1)==0,"casualties distinguished from prisoners")
	var shaken=scenario(data);shaken.state.units[0].morale="shaken"
	check(shaken.fire(0,4).event.loss<shot.event.loss,"shaken fire weaker at equal seed")
	e.fire(0,4)
	check(e.state.units[4].morale!="routed","two ordinary volleys no longer rout fresh regiment")
	e=scenario(data);e.apply_losses(4,450)
	check(e.state.units[4].morale=="routed","major losses can rout regiment")
	var retreat=e.retreat(4)
	check(retreat.route.size()>1 and e.state.units[4].ap==0,"rout retreats and ends activation")
	e.end_side()
	check(e.rally_status(4)=="ok","safe routing unit can rally on own turn")
	check(e.reach(4).costs.is_empty() and e.fire_status(4,0)=="routed","routing unit cannot move or shoot")
	check(e.rally(4) and e.state.units[4].morale=="shaken" and e.state.units[4].ap==8,"rally improves one state for two PA")
	check(not e.rally(4),"only one rally per turn")
	e.end_side();e.end_side()
	check(e.state.units[4].morale=="stable","quiet cycle after rally naturally restores stability")
	e=scenario(data);e.state.side=1;e.state.units[4].morale="shaken"
	check(e.rally_status(4)=="danger" and not e.rally(4),"nearby enemy prevents active rally")
	e=scenario(data);e.apply_losses(4,410)
	for cell_index in e.neighbours(e.unit_cell(e.state.units[4])):
		if e.unit_at(cell_index)<0:e.pack.map.tiles[cell_index]="water"
	shot=e.fire(0,4)
	check(shot.event.prisoners>0 and not e.alive(4),"blocked routed retreat causes surrender")
	check(e.losses(1)+e.prisoners(1)==1000,"surrender does not count survivors as casualties")
	check(e.validate(e.state),"surrender state valid")
	var save=Store.new("user://morale_test.json","m04");save.save_game(e);var restored=Rules.new(e.pack)
	check(save.load_game(restored) and restored.state==e.state,"surrender and journal round trip")
	e=scenario(data);e.state.units[4].cell=e.pack.objective.cell.duplicate();e.state.units[4].morale="routed";e.state.side=1
	e.end_side();check(e.state.scores==[0,0],"routing garrison cannot score")
	var brain=Brain.new();e=scenario(data)
	var hidden_view=e.observation(0,[])
	check(hidden_view.state.units.all(func(u):return int(u.side)==0),"observation excludes hidden enemies")
	check(hidden_view.pack.units.all(func(u):return int(u.side)==0),"pack does not leak hidden initial positions")
	var before=hidden_view.duplicate(true);var decision=brain.choose(hidden_view)
	check(hidden_view==before and decision.kind not in ["fire","assault"],"AI cannot attack hidden enemy or mutate observation")
	decision=brain.choose(e.observation(0,visible(e)))
	check(decision.kind=="fire" and apply(e,decision),"AI fires rather than assaulting equal fresh strength")
	e=scenario(data);e.state.units[4].strength=400;e.state.units[4].casualties=600
	decision=brain.choose(e.observation(0,visible(e)))
	check(decision.kind=="assault" and apply(e,decision),"AI assaults weakened adjacent enemy")
	e=scenario(data);e.state.units[0].morale="routed";e.state.units[0].cell=[0,0]
	decision=brain.choose(e.observation(0,visible(e)))
	check(decision.kind=="rally" and decision.unit==e.state.units[0].id,"AI rallies safely")
	e=Rules.new(data);e.new_game(1);decision=brain.choose(e.observation(0,visible(e)));apply(e,decision)
	save=Store.new("user://morale_test.json","ai-resume04");save.save_game(e);restored=Rules.new(data)
	check(save.load_game(restored) and restored.state==e.state and restored.state.human_side==1,"save during AI turn preserves camp and exact state")
	var resumed_decision=brain.choose(restored.observation(int(restored.state.side),visible(restored)))
	check(resumed_decision==brain.choose(e.observation(int(e.state.side),visible(e))),"AI resumes with same legal decision")
	check(apply(restored,resumed_decision) and restored.validate(restored.state),"AI continues after reload")
	var max_us=0;var total_actions=0;var total_shots=0;var total_assaults=0
	for seed_value in [13,71,1870,2026]:
		e=Rules.new(data);e.state.seed=seed_value
		var steps=0;var legal=true;var valid=true
		while not e.state.finished and steps<250:
			var start=Time.get_ticks_usec();decision=brain.choose(e.observation(int(e.state.side),visible(e)));max_us=maxi(max_us,Time.get_ticks_usec()-start)
			if not apply(e,decision):legal=false;break
			if not e.validate(e.state):valid=false;break
			steps+=1
		check(legal and valid,"all AI actions legal and state valid seed %d"%seed_value)
		check(e.state.finished and steps<250,"AI full battle terminates seed %d"%seed_value)
		check(e.state.shots>0 and e.state.moves>0,"AI engages and manoeuvres seed %d"%seed_value)
		check(e.state.scores[0]+e.state.scores[1]>0,"AI captures objective seed %d"%seed_value)
		total_actions+=steps;total_shots+=e.state.shots;total_assaults+=e.state.assaults
		print("Battle %d: scores %s losses %d/%d prisoners %d/%d assaults %d"%[seed_value,str(e.state.scores),e.losses(0),e.losses(1),e.prisoners(0),e.prisoners(1),e.state.assaults])
	print("AI simulations: %d actions, %d shots, %d assaults, slowest decision %.1f ms"%[total_actions,total_shots,total_assaults,max_us/1000.0])
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://morale_test.json"+suffix)
	print("MORALE/AI CHECKS: %d passed / %d"%[checks-failures,checks]);quit(1 if failures else 0)
