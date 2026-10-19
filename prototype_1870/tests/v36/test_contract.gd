extends "res://tests/test_strict0833.gd"
const Store=preload("res://war_engine/platform/save_store.gd")
func _initialize():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));var e=Rules.new(p)
	check(e.width==30 and e.height==20 and e.pack.map.tiles.size()==600,"30 by 20 map")
	check(e.state.units.size()==81,"81 declared units including reinforcements")
	check(e.pack.rules.turns==20 and e.pack.rules.minutes==30 and e.pack.rules.start_hour==8,"20 half hour turns from 08:00")
	check(e.pack.rules.ap==16,"base four PA")
	var pending=0;var arms={};var hq=0
	for n in range(e.state.units.size()):
		check(e.action_budget(e.state.units[n])==16,"base four PA unit "+str(n))
		if e.state.units[n].pending:pending+=1
		if e.headquarters(n):hq+=1
		if e.cavalry(n):
			arms.cavalry=true;check(e.pack.unit_types.cavalry.charge_ap==8 and (not e.alive(n) or e.assault_cost(n)==8),"cavalry charge two PA when active")
		elif e.artillery(n):arms.artillery=true
		else:arms.infantry=true
	check(arms.size()==3 and pending>0 and hq>0,"three arms, HQ and scheduled arrivals")
	check(e.pack.weapons.french_rifled.ap==12 and e.pack.weapons.french_rifled.range==6,"French cannon three PA six hexes")
	check(e.pack.weapons.krupp.ap==8 and e.pack.weapons.krupp.range==8,"Krupp two PA eight hexes")
	check(e.pack.rules.assault.ap==12 and e.pack.rules.entrenchment.ap==8,"assault three PA entrenchment two PA")
	check(e.pack.rules.victory.final_control==60 and e.pack.rules.victory.military==20 and e.pack.rules.victory.duration==20,"score 60/20/20")
	var goals=e.objective_definitions();check(goals.size()==3 and goals[0].points==3 and goals[1].points==2 and goals[2].points==1,"three goals weighted 3/2/1")
	check(e.validate(e.state),"full original scenario valid")
	while not e.state.finished:e.end_side()
	check(e.state.turn==20 and e.state.finished,"ends at twenty without extra turn")
	var waiting=0
	for u in e.state.units:
		if u.pending:waiting+=1
	check(waiting==0,"all scheduled reinforcement arrivals exposed during full 20 turns")
	check(e.validate(e.state),"full 81 unit quiet battle final valid")
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json");var copy=Rules.new(p);var saved="res://tests/v36/fixtures/v35_regimental.json"
	var target="user://v35_import.json";var f=FileAccess.open(target,FileAccess.WRITE);f.store_string(FileAccess.get_file_as_string(saved));f.close()
	var store=Store.new(target,raw.sha256_text(),p.save_migrations);check(store.load_game(copy) and copy.validate(copy.state) and copy.state.units.size()==81,"actual V35 engine save loads unchanged hash")
	print("V36 CONTRACT ",checks-failures,"/",checks);quit(1 if failures else 0)
