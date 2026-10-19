extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
var checks=0
var failures=0
var data: Dictionary
func check(ok: bool,msg: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+msg)
func scenario():
	var p=data.duplicate(true);p.map.tiles.fill("plain");var e=Rules.new(p)
	for n in range(e.state.units.size()):e.state.units[n].cell=[n*2,18]
	e.state.units[0].cell=[5,5];e.state.units[4].cell=[5,10];e.state.contacts=[{},{}];e.state.revealed=[[],[]];e.refresh_intel()
	return e
func _initialize():
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy088.json"))
	var e=scenario()
	check(e.assault_cost(10)==8 and e.assault_cost(0)==12,"charge 2 PA, infantry assault 3 PA")
	check(not e.visible_to(0,4) and e.known_unit_at(e.unit_cell(e.state.units[4]),0)<0,"enemy beyond observer range hidden")
	check(e.fire_status(0,4)=="hidden" and e.assault_status(0,4)=="hidden","hidden enemy cannot be attacked")
	e.state.units[10].cell=[6,5];e.refresh_intel()
	check(e.visible_to(0,4) and int(e.contact(4,0).level)==1,"cavalry detects beyond infantry range")
	check(e.contact(4,0).name_key=="fog_infantry" and e.contact(4,0).morale=="unknown","spotted contact has no regiment identity or exact state")
	check(not e.contact(4,0).has("ap") and not e.contact(4,0).has("strength"),"reports omit PA and exact strength")
	e.state.units[10].cell=[5,8];e.refresh_intel()
	check(int(e.contact(4,0).level)==2 and e.contact(4,0).name_key=="unit_1_0","near observer identifies unit")
	check(int(e.contact(4,0).low)<=e.state.units[4].strength and int(e.contact(4,0).high)>=e.state.units[4].strength,"estimated range contains actual strength")
	e.pack.map.tiles[e.unit_cell(e.state.units[4])]="forest";e.refresh_intel()
	check(int(e.contact(4,0).level)==1,"woodland conceals identity at two cells")
	e.state.units[10].cell=[5,7];e.refresh_intel();check(not e.visible_to(0,4),"woodland target concealed beyond two cells")
	e.state.units[10].cell=[5,9];e.refresh_intel();check(int(e.contact(4,0).level)==2,"adjacent woodland target identified")
	e=scenario();e.state.units[4].cell=[5,9];e.pack.map.tiles[e.index(Vector2i(5,7))]="hill";e.refresh_intel()
	check(not e.visible_to(0,4),"intervening ridge masks enemy")
	e.pack.map.tiles[e.index(Vector2i(5,7))]="forest";e.refresh_intel();check(not e.visible_to(0,4),"intervening woodland masks enemy")
	e=scenario();e.pack.map.tiles[e.unit_cell(e.state.units[0])]="hill";e.refresh_intel();check(e.visible_to(0,4),"height extends observation to five cells")
	# Stale report must keep old coordinates, not track hidden movement.
	e=scenario();e.state.units[4].cell=[5,9];e.refresh_intel();var old=e.contact(4,0).duplicate(true)
	e.state.units[0].cell=[1,1];e.state.units[4].cell=[5,11];e.refresh_intel()
	check(not e.visible_to(0,4) and e.contact(4,0)==old,"lost contact frozen at last position")
	e.state.units[0].cell=[5,8];e.state.units[4].cell=[28,1];e.refresh_intel()
	check(e.contact(4,0).is_empty(),"reobserved empty location clears stale contact")
	# Hidden enemy position must not affect reach/path previews or AI input/decision.
	e=scenario();e.state.units[0].cell=[3,3];e.state.units[4].cell=[12,5];e.refresh_intel();var twin=Rules.new(e.pack);twin.state=e.state.duplicate(true);twin.state.units[4].cell=[14,5];twin.state.units[4].strength=123;twin.state.units[4].casualties=877;twin.state.seed=999;twin.state.moves=19;twin.refresh_intel()
	check(e.reach(0,true)==twin.reach(0,true),"hidden occupancy does not change path planning")
	var v=e.observation(0,[4,5,6,7,9,11]);var v2=twin.observation(0,[4,5,6,7,9,11])
	check(v==v2,"twin worlds produce identical AI observations despite hidden changes and caller-supplied enemy list")
	check(not v.state.has("contacts") and not v.state.has("revealed") and v.state.events.is_empty(),"AI does not receive opponent intel or event log")
	check(AI.new().choose(v)==AI.new().choose(v2),"AI decision independent of hidden truth")
	for u in v.pack.units:check(int(u.side)==0 or e.visible_to(0,e.unit_index(str(u.id))),"pack includes only own or observed unit "+str(u.id))
	# Discovery during movement stops early, spends only travelled PA and removes Undo.
	e=scenario();e.state.units[0].cell=[5,3];e.state.units[4].cell=[5,8];e.state.contacts=[{},{}];e.refresh_intel()
	var route=[e.index(Vector2i(5,3)),e.index(Vector2i(5,4)),e.index(Vector2i(5,5))];var result=e.move(0,route)
	check(result=="discovered" and e.state.units[0].cell==[5,4] and e.state.units[0].ap==13,"discovery stops column after one step, charges actual cost")
	check(e.visible_to(0,4) and not e.undo() and e.validate(e.state),"discovery cannot be undone and state valid")
	e=scenario();e.state.units[0].cell=[1,1];e.refresh_intel();var before=e.state.duplicate(true)
	check(e.move(0,[e.index(Vector2i(1,1)),e.index(Vector2i(1,2))])=="moved" and e.undo() and JSON.parse_string(JSON.stringify(e.state))==JSON.parse_string(JSON.stringify(before)),"safe move can still be undone")
	# Own artillery may use shared spotting; firing reveals it to the other camp.
	e=scenario();e.state.units[0].cell=[1,1];e.state.units[8].cell=[5,3];e.state.units[8].deployed=true;e.state.units[10].cell=[8,7];e.state.units[4].cell=[5,9];e.refresh_intel()
	check(e.visible_to(0,4) and not e.visible_to(1,8),"shared reconnaissance sees target while gun is hidden")
	var fired=e.fire(8,4);check(fired.status=="ok" and e.visible_to(1,8),"firing reveals attacking gun")
	if fired.status=="ok":check(fired.event.has("fog_names"),"combat stores observer-specific journal identities")
	var saver=Store.new("user://fog086_test.json","fog086");check(saver.save_game(e),"fog save written");var copy=Rules.new(e.pack)
	var loaded=saver.load_game(copy)
	if not loaded:print("SAVE DEBUG valid=",e.validate(e.state))
	elif copy.state!=e.state:
		for key in e.state:
			if copy.state.get(key)!=e.state[key]:print("SAVE DIFF ",key," ",copy.state.get(key)," versus ",e.state[key])
	check(loaded and copy.state==e.state,"contacts revelations and combat survive exact save roundtrip")
	var bad=e.state.duplicate(true);bad.contacts[0]["999"]={};check(not e.validate(bad),"invalid saved contact rejected")
	# Full AI run validates all commands with actual side visibility.
	e=Rules.new(data);e.state.seed=123;var ai=AI.new();var steps=0;var started=Time.get_ticks_msec()
	while not e.state.finished and steps<400:
		steps+=1;var choice=ai.choose(e.observation(int(e.state.side)));var n=e.unit_index(str(choice.get("unit","")));var ok=true
		match choice.kind:
			"end":e.end_side()
			"move":ok=e.move(n,choice.path) in ["moved","capture","discovered"]
			"fire":ok=e.fire(n,e.unit_index(choice.target)).status=="ok"
			"assault":ok=e.assault(n,e.unit_index(choice.target)).status=="ok"
			"formation":ok=e.change_formation(n,choice.formation)
			"rally":ok=e.rally(n)
			"entrench":ok=e.entrench(n)
			"deploy","limber":ok=e.toggle_deployment(n)
			_:ok=false
		if not ok or not e.validate(e.state):check(false,"AI fog command/state "+str(choice));break
	check(e.state.finished and steps<400,"AI fog scenario finishes")
	print("AI steps: %d; desktop ms: %d"%[steps,Time.get_ticks_msec()-started])
	print("FOG 086: %d / %d passed"%[checks-failures,checks]);quit(1 if failures else 0)
