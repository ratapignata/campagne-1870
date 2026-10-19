extends "res://tests/test_ai_compat0833.gd"
func duel(size: int):
	var p=data.duplicate(true);p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.map.road_edges=[];p.rules.support.enabled=false;p.rules.fog.enabled=false
	var f=p.units[0].duplicate(true);var d=p.units[34].duplicate(true)
	f.cell=[10,10];d.cell=[10,11];f.arrival_turn=1;d.arrival_turn=1;f.initial_strength=1000;d.initial_strength=size;p.units=[f,d]
	var e=Rules.new(p);e.new_game(0,"medium");e.state.side=1;e.state.ai_style=0
	for u in e.state.units:u.formation="line";u.ap=16;u.done=false
	return e
func _initialize():
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_experimental.json"))
	var report={"fixture":"Synthetic plain, adjacent Dreyse against 1000 Chassepot, line formation, no support/fog; existing rules unchanged","samples":[],"checks":0,"failures":0}
	for size in [1000,2000,2900,4577]:
		var e=duel(size);var sum=0.0;var power=e.attack_power_against(1,0);var defence=e.defence_power_against(0,1)
		for seed_value in range(1000):
			var rng=RandomNumberGenerator.new();rng.seed=420000+seed_value;sum+=e.shot_loss(1,0,rng)
		var wins=0;var inflicted=0.0;var suffered=0.0
		for seed_value in range(64):
			e=duel(size);e.state.seed=420000+seed_value;var r=e.assault(1,0)
			check(r.status=="ok","legal same-rules assault")
			if r.status=="ok":
				if r.event.outcome!="repulsed":wins+=1
				inflicted+=r.event.loss;suffered+=r.event.return_loss
		report.samples.append({"german_strength":size,"mean_shot_loss":sum/1000,"attack_power":power,"defence_power":defence,"assault_ratio":power/defence,"non_repulsed_of_64":wins,"assault_mean_inflicted":inflicted/64,"assault_mean_suffered":suffered/64})
	check(report.samples[0].mean_shot_loss==report.samples[3].mean_shot_loss,"full-strength shot damage has no absolute strength multiplier")
	check(report.samples[3].assault_ratio>4.0*report.samples[0].assault_ratio,"large units scale assault power: balance risk exposed")
	report.checks=checks;report.failures=failures
	var f=FileAccess.open("user://balance_v42.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	print("V42 BALANCE ",JSON.stringify(report));quit(1 if failures else 0)
