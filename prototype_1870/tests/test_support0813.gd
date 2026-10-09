extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Store=preload("res://war_engine/platform/save_store.gd")
const AI=preload("res://war_engine/ai/tactical_ai.gd")
var checks=0
var failures=0
func check(ok: bool,message: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+message)
func fresh():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0813.json"));p.rules.fog.enabled=false;p.map.tiles.fill("plain")
	var e=Rules.new(p)
	return e
func _initialize():
	var e=fresh()
	check(e.validate(e.state),"new support state valid")
	for u in e.state.units:check(u.ammo_level==0 and u.supply_ok,"fresh reserves and links")
	for k in range(3):e.spend_ammo(0)
	check(e.state.units[0].ammo_level==1 and e.state.units[0].ammo_spent==0,"three volleys -> correct")
	for k in range(30):e.spend_ammo(0)
	check(e.state.units[0].ammo_level==2,"no fourth ammunition state")
	e.state.units[0].cell=[10,5];e.state.units[4].cell=[11,5];e.state.units[0].formation="line";e.state.units[4].formation="line"
	var weak=e.shot_loss(0,4,e.combat_rng());e.state.units[0].ammo_level=0
	var full=e.shot_loss(0,4,e.combat_rng());check(weak<full and absf(float(weak)/full-0.65)<0.03,"low ammunition affects fire")
	var result=e.fire(0,4);check(result.status=="ok" and result.event.reaction,"actual exchange and reaction")
	check(e.state.units[0].ammo_spent==1 and e.state.units[4].ammo_spent==1,"both shots consume reserves")
	e=fresh();e.state.units[0].cell=[0,0];e.update_support(0)
	check(not e.state.units[0].command_ok and e.state.units[0].supply_ok,"command isolation distinct from supply")
	e.state.units[0].morale="shaken";e.state.units[0].cohesion=50
	check(e.rally_cost(0)==8 and e.rally(0) and e.state.units[0].ap==8,"isolated rally exactly two PA")
	e=fresh();e.state.units[0].cell=[0,0];e.state.units[0].morale="shaken";e.state.units[0].cohesion=40;e.state.side=1;e.end_side()
	check(e.state.units[0].cohesion==58 and e.state.units[0].morale=="shaken","half recovery without command")
	check(e.state.units[0].ap==16,"no automatic PA penalty")
	e=fresh();e.state.units[0].ammo_level=2;e.state.units[0].ammo_spent=2
	check(e.rest(0) and e.state.units[0].done and e.state.units[0].ammo_level==2,"rest has no instant refill")
	e.end_side();e.end_side();check(e.state.units[0].ammo_level==1 and e.state.units[0].ammo_spent==0,"one level replenished after quiet cycle")
	e=fresh();e.state.units[0].ammo_level=2;e.state.units[0].quiet=false;e.state.units[0].attacked=true;e.end_side();e.end_side()
	check(e.state.units[0].ammo_level==2,"voluntary fire prevents recovery")
	e=fresh();e.state.units[0].ammo_level=2;e.state.units[0].supply_ok=false;e.state.side=1;e.end_side()
	check(e.state.units[0].supply_ok and e.state.units[0].ammo_level==2,"reconnection does not refill immediately")
	# A wall has only one passage. Enemy occupation severs it, no arbitrary radius.
	e=fresh()
	for y in range(e.height):e.pack.map.tiles[e.index(Vector2i(5,y))]="water"
	e.pack.map.tiles[e.index(Vector2i(5,10))]="bridge";e.state.units[4].cell=[5,10];e.update_support(0)
	check(not e.state.units[0].supply_ok and e.state.units[0].encircled,"blocked bridge cuts all paths")
	e.state.units[0].ammo_level=2;e.state.side=1;e.end_side()
	check(e.state.units[0].ammo_level==2 and e.state.units[0].strength==e.state.units[0].initial_strength and e.state.units[0].morale=="stable","isolation has no automatic casualties or morale shock")
	e.state.units[4].cell=[22,2];e.update_support(0);check(e.state.units[0].supply_ok,"opened bridge reconnects supply")
	# Friendly held corridor overrides hostile ZOC, but never enemy occupation.
	e.state.units[4].cell=[6,10];e.state.units[1].cell=[5,10];e.update_support(0)
	check(e.state.units[1].supply_ok,"friendly occupied bridge holds a corridor")
	e=fresh();var center=e.index(Vector2i(10,10));e.state.units[0].cell=[10,10]
	var ring=e.neighbours(center);var foes=[4,5,6,7,9,11]
	for k in range(6):var c=e.cell(ring[k]);e.state.units[foes[k]].cell=[c.x,c.y]
	e.update_support(0);check(e.state.units[0].encircled,"complete ring detected")
	var retreat=e.retreat(0);check(retreat.prisoners==0 and e.alive(0) and e.state.units[0].cohesion==95,"orderly surrounded unit holds with limited shock")
	e.state.units[0].morale="routed";retreat=e.retreat(0)
	check(retreat.prisoners==int(e.state.units[0].initial_strength) and e.state.units[0].casualties==0 and not e.alive(0),"trapped routed survivors captured separately")
	# Enemy support secrets are absent from the sanitized AI observation.
	e=fresh();var view=e.observation(0,[4]);var original=JSON.stringify(view)
	e.state.units[4].ammo_level=2;e.state.units[4].supply_ok=false;e.state.units[4].command_ok=false;e.state.units[4].encircled=true
	check(JSON.stringify(e.observation(0,[4]))==original,"AI observation does not leak enemy logistics")
	var ai=AI.new();ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var choice=ai.choose(view);check(not choice.is_empty(),"AI can plan with sanitized support data")
	e=fresh();e.state.units[0].ammo_level=2;e.state.units[0].ammo_spent=1;e.state.units[0].command_ok=false
	var saver=Store.new("user://support089_test.json","support089")
	check(saver.save_game(e),"save write")
	var restored=fresh();check(saver.load_game(restored) and restored.state==e.state,"save exact roundtrip")
	var bad=e.state.duplicate(true);bad.units[0].ammo_level=3;check(not e.validate(bad),"reject fourth level in save")
	bad=e.state.duplicate(true);bad.units[0].ammo_spent=0.5;check(not e.validate(bad),"reject fractional salvo counter")
	var legacy=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy088.json")))
	check(not legacy.support_enabled() and legacy.validate(legacy.state),"old pack preserves previous rules")
	# Damage and automatic responses affect morale quietness, not resupply eligibility.
	for side in [0,1]:
		var own=0 if side==0 else 4;var foe=4 if side==0 else 0
		e=fresh();e.state.side=side
		for n in range(e.state.units.size()):e.state.units[n].cell=[1 if e.state.units[n].side==0 else 28,n]
		e.state.units[own].cell=[10+side,8];e.state.units[foe].cell=[11-side,8]
		e.state.units[own].ammo_level=2;e.state.units[own].ammo_spent=1
		e.end_side()
		var exchange=e.fire(foe,own)
		check(exchange.status=="ok" and exchange.event.reaction,"both camps: real reply available")
		check(not e.state.units[own].attacked and not e.state.units[own].quiet and e.state.units[own].ammo_spent==2,"reply consumes ammo, losses are not voluntary attack")
		e.end_side()
		check(e.state.units[own].ammo_level==1 and e.state.units[own].ammo_spent==0,"adjacent defender resupplies despite reply and losses: "+JSON.stringify(e.state.units[own]))
		e=fresh();e.state.side=side
		for n in range(e.state.units.size()):e.state.units[n].cell=[1 if e.state.units[n].side==0 else 28,n]
		e.state.units[own].cell=[10+side,8];e.state.units[foe].cell=[11-side,8]
		e.state.units[own].ammo_level=2
		check(e.assault(own,foe).status=="ok" and e.state.units[own].attacked,"assault marks voluntary attack")
		e.end_side();e.end_side();check(e.state.units[own].ammo_level==2,"assault blocks recovery")
	e=fresh();e.state.units[0].ammo_level=2;e.apply_losses(0,1)
	check(e.rest_status(0)=="ok","received losses do not block rest")
	e.end_side();e.end_side();check(e.state.units[0].ammo_level==1,"received losses permit recovery")
	e=fresh();e.state.units[0].ammo_level=2;e.state.units[0].morale="routed";e.state.units[0].cohesion=0
	e.end_side();e.end_side();check(e.state.units[0].ammo_level==2,"rout prevents refill")
	e=fresh();e.state.units[0].ammo_level=2;e.state.units[0].attacked=true
	var mid=Store.new("user://support0813_mid.json","0813")
	check(mid.save_game(e),"save mid cycle")
	var reload=fresh();check(mid.load_game(reload) and reload.state.units[0].attacked,"reload preserves voluntary attack")
	reload.end_side();reload.end_side();check(reload.state.units[0].ammo_level==2,"reload cannot bypass spent cycle")
	reload.end_side();reload.end_side();check(reload.state.units[0].ammo_level==1,"next calm cycle recovers")
	var prev=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0811.json")))
	prev.state.units[0].ammo_level=2;prev.apply_losses(0,1);prev.end_side();prev.end_side()
	check(not prev.relaxed_supply() and prev.state.units[0].ammo_level==2,"0811 and 0812 saves keep strict resupply")
	e=fresh();var secret=e.observation(0,[4]);e.state.units[4].attacked=true;e.state.units[4].supply_interrupted=true
	check(JSON.stringify(secret)==JSON.stringify(e.observation(0,[4])),"new logistics flags remain private")
	print("SUPPORT 0813: %d/%d passed"%[checks-failures,checks]);quit(1 if failures else 0)
