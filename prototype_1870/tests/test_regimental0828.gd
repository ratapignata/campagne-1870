extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func _initialize():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"))
	var e=Rules.new(p)
	check(e.state.units.size()==81,"81 units")
	check(e.validate(e.state),"initial state valid")
	var pending=0
	for n in range(e.state.units.size()):
		if e.state.units[n].get("pending",false):
			pending+=1;check(not e.alive(n) and not e.can_act(n),"reserve inactive")
	check(pending>0,"reserves present")
	for side in [0,1]:
		var view=e.observation(side)
		for u in view.state.units:check(not u.get("pending",false),"no future reserve in AI view")
	# Save JSON round trip before arrivals.
	var copy=Rules.new(p);copy.state=JSON.parse_string(JSON.stringify(e.state));copy.normalize()
	check(copy.validate(copy.state),"save round trip pending")
	for phase in range(9):
		e.end_side();check(e.validate(e.state),"arrival state valid")
	for u in e.state.units:check(not u.get("pending",false),"all unblocked waves entered")
	copy.state=JSON.parse_string(JSON.stringify(e.state));copy.normalize();check(copy.validate(copy.state),"save round trip arrived")
	# Entry occupied: reinforce waits without displacing friendly occupant.
	e=Rules.new(p)
	var reserve=-1;var active=-1
	for n in range(e.state.units.size()):
		if int(e.state.units[n].side)!=0:continue
		if e.state.units[n].get("pending",false):reserve=n
		else:active=n
	var old=e.state.units[active].cell.duplicate()
	e.state.units[active].cell=e.state.units[reserve].cell.duplicate();e.state.turn=5;e.state.side=0;e.arrive_reinforcements()
	check(e.state.units[reserve].pending,"blocked entry waits")
	e.state.units[active].cell=old;e.arrive_reinforcements();check(not e.state.units[reserve].pending,"entry resumes when free")
	for side in [0,1]:
		e=Rules.new(p);e.new_game(side,"medium");e.state.side=side
		var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
		var start=Time.get_ticks_msec();var d=ai.choose(e.observation(side));print("AI initial side ",side," ",Time.get_ticks_msec()-start,"ms ",d.kind)
		check(d.has("kind"),"AI decision")
	e=Rules.new(p)
	for phase in range(36):
		if not e.state.finished:e.end_side()
	check(e.state.finished and e.validate(e.state),"battle reaches result")
	print("REGIMENTAL ",checks-failures,"/",checks);quit(1 if failures else 0)
