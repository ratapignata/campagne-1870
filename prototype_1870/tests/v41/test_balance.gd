extends "res://tests/test_ai_compat0833.gd"
func setup_duel():
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"))
	p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[]
	var f=p.units[0].duplicate(true);var d=p.units[34].duplicate(true)
	f.cell=[10,10];d.cell=[10,12];f.arrival_turn=1;d.arrival_turn=1;p.units=[f,d]
	var e=Rules.new(p);e.new_game(0,"medium")
	for u in e.state.units:
		u.initial_strength=1000;u.strength=1000;u.casualties=0;u.ap=16;u.done=false;u.morale="steady";u.formation="line";u.entrenched=false;u.ammo_level=0
	e.refresh_intel();return e
func _initialize():
	var e=setup_duel();var report={"samples":5000,"duels_per_initiator":256,"shots":{},"duels":{}}
	check(e.distance(e.unit_cell(e.state.units[0]),e.unit_cell(e.state.units[1]))==2,"exact two-hex separation")
	check(is_equal_approx(float(e.pack.weapons.chassepot.distance_factors[1]),0.60),"supplied V41 Chassepot factor")
	check(is_equal_approx(float(e.pack.weapons.dreyse.distance_factors[1]),0.52),"supplied V41 Dreyse factor")
	for n in [0,1]:
		var sum=0.0;var lo=100000;var hi=0
		for seed_value in range(5000):
			var rng=RandomNumberGenerator.new();rng.seed=410000+seed_value
			var loss=e.shot_loss(n,1-n,rng);sum+=loss;lo=mini(lo,loss);hi=maxi(hi,loss)
		report.shots[str(e.state.units[n].weapon)]={"mean":sum/5000,"min":lo,"max":hi}
	var ratio=report.shots.chassepot.mean/report.shots.dreyse.mean
	check(ratio>1.14 and ratio<1.17,"measured weapon advantage remains near 15.38 percent")
	for side in [0,1]:
		var damage=0.0;var response=0.0
		for seed_value in range(256):
			e=setup_duel();e.state.side=side;e.state.seed=410000+seed_value
			var budget=int(e.state.units[1-side].reactions);var ap=int(e.state.units[side].ap)
			var result=e.fire(side,1-side)
			check(result.status=="ok","legal full exchange")
			if result.status!="ok":continue
			check(result.event.reaction and int(e.state.units[1-side].reactions)==budget-1,"existing reaction and budget")
			check(int(e.state.units[side].ap)==ap-int(e.weapon(side).ap),"shot costs preserved")
			damage+=result.event.loss;response+=result.event.return_loss
		report.duels[str(side)]={"mean_damage":damage/256,"mean_return_loss":response/256}
	report.ratio=ratio;report.checks=checks;report.failures=failures
	var out=FileAccess.open("user://balance.json",FileAccess.WRITE);out.store_string(JSON.stringify(report,"\t"));out.close()
	print("V41 BALANCE ",JSON.stringify(report));quit(1 if failures else 0)
