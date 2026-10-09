extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
const Legacy=preload("res://war_engine/ai/legacy_ai.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
var profiles: Dictionary
var data: Dictionary
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func bot():
	var ai=AI.new();ai.profiles=profiles;return ai
func fixture():
	var p=data.duplicate(true);p.map.tiles.fill("plain");var e=Rules.new(p)
	for n in range(e.state.units.size()):
		e.state.units[n].strength=0;e.state.units[n].casualties=e.state.units[n].initial_strength;e.state.units[n].done=true
	e.state.contacts=[{},{}];e.state.revealed=[[],[]];return e
func revive(e,n: int,cell: Array):
	var u=e.state.units[n];u.strength=u.initial_strength;u.casualties=0;u.cell=cell;u.done=false;u.ap=16;u.formation="none" if e.artillery(n) or e.cavalry(n) else "line"
func dispatch(e,d: Dictionary) -> bool:
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
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0813.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var ai=bot();var reference={}
	for difficulty in ["easy","medium","hard"]:
		var e=Rules.new(data);e.new_game(1,difficulty);e.state.seed=123;e.state.ai_style=0
		var comparable=e.state.duplicate(true);comparable.erase("ai_difficulty")
		if reference.is_empty():reference=comparable
		check(comparable==reference and e.pack==data,"no change in military rules/units/AP: "+difficulty)
		var view=e.observation(0);var before=view.duplicate(true);var chosen=ai.choose(view)
		check(view==before,"AI does not mutate observed input: "+difficulty)
		check(dispatch(e,chosen) and e.validate(e.state),"first command valid: "+difficulty)
		var store=Store.new("user://ai088_"+difficulty+".json","ai088");var copy=Rules.new(data)
		check(store.save_game(e) and store.load_game(copy) and copy.state==e.state,"difficulty/style save roundtrip: "+difficulty)
		# Two worlds share all visible information, with completely different hidden forces.
		e=fixture();revive(e,0,[2,2]);revive(e,4,[27,17]);e.state.ai_difficulty=difficulty;e.state.ai_style=1;e.refresh_intel()
		var twin=Rules.new(e.pack);twin.state=e.state.duplicate(true);twin.state.units[4].cell=[25,18];twin.state.units[4].strength=117;twin.state.units[4].casualties=883;twin.state.seed=8888;twin.refresh_intel()
		check(e.observation(0)==twin.observation(0),"no hidden information in observation: "+difficulty)
		check(ai.choose(e.observation(0))==ai.choose(twin.observation(0)),"decision independent of hidden enemy: "+difficulty)
	# Historic saves retain precisely their previous algorithm, including normalisation.
	var old=Rules.new(data);old.state.erase("ai_difficulty");old.state.erase("ai_style");old.normalize()
	check(old.state.ai_difficulty=="legacy","missing saved difficulty becomes legacy")
	var old_view=old.observation(0)
	check(ai.choose(old_view)==Legacy.new().choose(old_view),"legacy decision unchanged")
	var bad=old.state.duplicate(true);bad.ai_difficulty="cheat";check(not old.validate(bad),"invalid difficulty rejected")
	bad=old.state.duplicate(true);bad.ai_style=1.5;check(not old.validate(bad),"invalid style rejected")
	# Only high quality positions permit movement and firing in the same turn.
	var e=fixture();revive(e,0,[10,7]);revive(e,4,[10,11]);e.state.units[0].ap=12;e.state.units[0].formation="skirmish";e.state.ai_difficulty="hard";e.refresh_intel()
	var d=ai.choose(e.observation(0));print("MOVE/FIRE fixture: ",d)
	check(d.kind=="move" and e.path_cost(d.path,0)<=4,"hard keeps the two PA required for shooting")
	if d.kind=="move":
		dispatch(e,d);d=ai.choose(e.observation(0));check(d.kind=="fire","hard follows its firing approach with a shot")
	# Isolate charge odds against orderly infantry without a defensive volley.
	e=fixture();revive(e,10,[10,9]);revive(e,4,[10,10]);e.state.units[4].strength=800;e.state.units[4].casualties=200;e.pack.weapons[e.state.units[4].weapon].can_fire=false;e.pack.objective.cell=[10,10];e.state.owner=1;e.refresh_intel()
	var options={}
	for difficulty in ["easy","hard"]:
		e.state.ai_difficulty=difficulty;options[difficulty]=ai.choose(e.observation(0));print("CHARGE ",difficulty,": ",options[difficulty])
	check(options.easy!=options.hard,"difficulty changes a concrete tactical decision")
	if "--quick" in OS.get_cmdline_user_args():
		print("AI QUICK 088: %d / %d passed"%[checks-failures,checks]);quit(1 if failures else 0);return
	# Run both camps for every level; no privileged enemy data are passed to the bot.
	for difficulty in ["easy","medium","hard"]:
		e=Rules.new(data);e.new_game(0,difficulty);e.state.seed=123;e.state.ai_style=0
		var count=0;var worst=0;var started=Time.get_ticks_msec();var good=true
		while not e.state.finished and count<400:
			count+=1;var tick=Time.get_ticks_msec();d=ai.choose(e.observation(int(e.state.side)));worst=maxi(worst,Time.get_ticks_msec()-tick)
			if not dispatch(e,d) or not e.validate(e.state):print("BAD ",difficulty," ",d);good=false;break
		check(good and e.state.finished and count<400,"six-turn battle finishes with legal commands: "+difficulty)
		print("BATTLE ",difficulty," decisions=",count," total_ms=",Time.get_ticks_msec()-started," max_decision_ms=",worst," scores=",e.state.scores)
	print("AI 089: %d / %d passed"%[checks-failures,checks]);quit(1 if failures else 0)
