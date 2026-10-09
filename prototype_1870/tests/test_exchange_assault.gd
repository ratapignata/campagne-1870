extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
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
func strength(e,n,v):e.state.units[n].strength=v;e.state.units[n].casualties=e.state.units[n].initial_strength-v
func cycle(e):e.end_side();e.end_side()
func _initialize():
	var data=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/prototype08.json"));var e=scenario(data)
	e.state.units[4].ap=0;e.state.units[4].done=true
	var shot=e.fire(0,4);var ev=shot.event
	check(ev.reaction and ev.return_loss>0 and ev.loss>0,"both camps suffer losses with spent defender AP")
	check(e.state.units[4].ap==0 and e.state.units[4].reactions==0,"reaction uses separate budget without AP")
	check(e.losses(0)==ev.return_loss and e.losses(1)==ev.loss,"both side casualties exact")
	check(not e.fire(0,4).event.reaction,"second incoming volley cannot trigger second reaction")
	check(e.state.units[4].reactions==0,"reaction stays spent until next opposing turn")
	cycle(e)
	check(e.state.units[4].reactions==1 and e.fire(0,4).event.reaction,"reaction renewed once per opposing turn")
	e=scenario(data);e.state.units[4].cell=[5,8];ev=e.fire(0,4).event
	check(ev.loss>0 and not ev.reaction and ev.return_loss==0,"Chassepot outranges Dreyse without magic return casualties")
	e=scenario(data);e.state.units[4].morale="routed"
	check(not e.fire(0,4).event.reaction,"routed unit cannot return fire")
	e=scenario(data);e.state.units[0].cell=[5,5];e.state.units[9].cell=[5,6]
	check(not e.fire(0,9).event.reaction,"limbered cannon cannot react")
	e=scenario(data);e.state.units[9].cell=[5,6];e.state.units[4].cell=[8,18];e.state.units[9].deployed=true
	check(e.fire(0,9).event.reaction,"deployed cannon can react")
	e=scenario(data);e.state.units[4].cell=[5,7];e.pack.map.tiles[e.index(Vector2i(5,6))]="forest"
	check(e.reaction_status(4,0)=="blocked_cover","reaction respects LOS")
	e=scenario(data);strength(e,4,1)
	ev=e.fire(0,4).event
	check(ev.eliminated and ev.reaction and ev.return_loss>0,"simultaneous exchange evaluates defender before destruction")
	var damage=[]
	for distance_value in [1,2,3]:
		e=scenario(data);e.state.units[4].cell=[5,5+distance_value];damage.append(e.fire(0,4).event.loss)
	check(damage[0]>damage[1] and damage[1]>damage[2],"strict infantry damage falloff at equal seed")
	check(damage[2]<damage[0]/2,"long range reduction perceptible")
	e=scenario(data);e.fire(0,4);e.fire(0,4)
	check(e.state.units[4].morale!="routed","fresh infantry withstands two ordinary close volleys")
	e=scenario(data);e.state.units[4].cohesion=35;e.apply_losses(4,10)
	check(e.state.units[4].morale=="shaken","low cohesion alone does not rout unit with minor losses")
	e=scenario(data)
	for k in range(6):e.apply_losses(4,105)
	check(e.state.units[4].morale=="routed","accumulated heavy losses can cause rout")
	e=scenario(data);e.state.units[0].morale="shaken";e.state.units[0].cohesion=50
	cycle(e);check(e.state.units[0].morale=="stable","quiet cycle restores shaken unit")
	e=scenario(data);e.state.units[0].morale="shaken";e.state.units[0].cohesion=50;e.fire(0,4);cycle(e)
	check(e.state.units[0].morale=="shaken","firing prevents quiet recovery")
	e=scenario(data);e.state.units[0].morale="shaken";e.state.units[0].cohesion=50;e.apply_losses(0,1);cycle(e)
	check(e.state.units[0].morale=="shaken","receiving loss prevents quiet recovery")
	e=scenario(data);e.state.units[0].morale="shaken";e.state.units[0].cohesion=50
	e.move(0,e.path_to(0,e.index(Vector2i(4,4))));cycle(e)
	check(e.state.units[0].morale=="stable","ordinary movement permits quiet recovery")
	e=scenario(data);e.state.units[0].morale="routed";e.state.units[0].cell=[1,1];cycle(e)
	check(e.state.units[0].morale=="routed","rout never recovers without rally")
	e=scenario(data);strength(e,4,400);var old_target=e.unit_cell(e.state.units[4]);ev=e.assault(0,4).event
	check(e.state.assaults==1 and e.state.shots==0 and e.state.events.size()==1,"assault counted separately and logged once")
	check(e.state.units[0].ap==4,"assault costs exactly 3 PA")
	check(ev.reaction and ev.loss>0 and ev.return_loss>0,"assault includes defensive volley and bilateral melee casualties")
	check(ev.outcome=="taken" and e.unit_cell(e.state.units[0])==old_target and ev.advance.size()==2,"victorious assault automatically occupies vacated position")
	check(ev.retreat.size()>1 and e.state.units[4].morale!="routed","lost melee can force withdrawal without rout")
	check(not e.undo() and e.validate(e.state),"assault is irreversible and preserves valid state")
	var store=Store.new("user://assault_test.json","a04");store.save_game(e);var copy=Rules.new(e.pack)
	check(store.load_game(copy) and copy.state==e.state,"assault losses paths reaction and recovery flags survive reload")
	e=scenario(data);strength(e,4,400);e.state.units[4].reactions=0;ev=e.assault(0,4).event
	check(not ev.reaction and ev.return_loss>0,"spent reaction still permits contact defence")
	e=scenario(data);strength(e,0,400);ev=e.assault(0,4).event
	check(ev.outcome=="repulsed" and e.unit_cell(e.state.units[4])==e.index(Vector2i(5,6)),"weak assault fails and defender holds")
	check(ev.attacker_retreat.size()>1 or ev.attacker_eliminated,"failed attacker withdraws or is destroyed")
	e=scenario(data);e.pack.weapons.dreyse.base_losses=800;ev=e.assault(0,4).event
	check(ev.outcome=="repulsed" and ev.loss==0 and ev.attacker_new_morale=="routed","devastating defensive volley halts assault before contact")
	e=scenario(data);e.state.units[0].ap=11;var before=e.state.duplicate(true)
	check(e.assault(0,4).status=="no_ap" and e.state==before,"insufficient assault AP rejected atomically")
	e=scenario(data);e.state.units[4].cell=[5,7];before=e.state.duplicate(true)
	check(e.assault(0,4).status=="range" and e.state==before,"nonadjacent assault rejected atomically")
	e=scenario(data);e.state.units[8].cell=[4,6]
	check(e.assault_status(8,4)=="artillery","cannon cannot initiate assault")
	check(e.assault_status(0,1)=="friendly","cannot assault own unit")
	e.state.units[0].morale="routed"
	check(e.assault_status(0,4)=="routed","routed infantry cannot assault")
	e=scenario(data);var plain=e.assault_power(4,true);e.pack.map.tiles[e.unit_cell(e.state.units[4])]="village"
	check(e.assault_power(4,true)>plain,"village improves melee defence")
	e=scenario(data);e.state.units[0].cell=[15,8];e.state.units[4].cell=e.pack.objective.cell.duplicate();strength(e,4,400)
	ev=e.assault(0,4).event
	check(ev.outcome=="taken" and e.state.owner==0,"successful assault captures objective")
	e.end_side();e.end_side();check(e.state.scores[0]==1,"assault garrison scores after both sides")
	e=scenario(data);e.fire(0,4);store.save_game(e);copy=Rules.new(e.pack);store.load_game(copy)
	check(copy.state.units[4].reactions==0 and not copy.fire(0,4).event.reaction,"reload cannot replenish spent reaction")
	check(e.fire(0,4).event==copy.state.events[-1],"reloading cannot reroll bilateral combat")
	var bad=e.state.duplicate(true);bad.units[4].reactions=2;check(not e.validate(bad),"invalid reaction budget save rejected")
	bad=e.state.duplicate(true);bad.events[0].return_loss=-1;check(not e.validate(bad),"negative attacker casualties save rejected")
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://assault_test.json"+suffix)
	print("EXCHANGE/ASSAULT CHECKS: %d passed / %d"%[checks-failures,checks]);quit(1 if failures else 0)
