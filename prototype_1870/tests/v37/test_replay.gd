extends "res://tests/v36/test_ai_active.gd"
const FullBattle=preload("res://tests/v37/test_full_battle.gd")
const Save=preload("res://war_engine/platform/save_store.gd")
# Replay the actual full battle, examining only observations available to each AI.
func _initialize():
	var report=JSON.parse_string(FileAccess.get_file_as_string("res://tests/results/0837/full_battle_report.json"))
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"))
	var e=Rules.new(p);e.new_game(0,report.difficulty);e.state.seed=int(report.seed);e.state.ai_style=int(report.ai_style)
	var idle=[];var awaiting=[];var surrenders=[];var diagnosis=AI.new()
	for action in report.actions:
		check(int(e.state.turn)==int(action.turn) and int(e.state.side)==int(action.side),"chronological action boundary")
		var d=action.decision
		if d.kind=="end":
			var view=e.observation(int(e.state.side));var observed=Rules.new(view.pack,view.state)
			for n in range(observed.state.units.size()):
				if not observed.can_act(n) or observed.headquarters(n) or observed.state.units[n].morale=="routed":continue
				var attacks=[];var progress=[];var start=observed.unit_cell(observed.state.units[n]);var reachable=observed.reach(n).costs
				diagnosis.offensive=int(observed.pack.ai.get("attacking_side",-1))==int(observed.state.side)
				var assigned=diagnosis.mission_goal(observed,n,{})
				for j in range(observed.state.units.size()):
					if observed.fire_status(n,j)=="ok" or observed.assault_status(n,j)=="ok":attacks.append(observed.state.units[j].id)
				for goal in observed.objective_definitions():
					if observed.objective_owner(goal)==int(e.state.side):continue
					var pos=observed.objective_cell(goal);var distance=observed.distance(start,pos)
					for dest in reachable:
						if observed.distance(int(dest),pos)<distance:progress.append(goal.id);break
				if not attacks.is_empty() or not progress.is_empty():idle.append({"turn":e.state.turn,"side":e.state.side,"unit":observed.state.units[n].id,"ap":observed.state.units[n].ap,"cell":observed.state.units[n].cell,"assigned_goal":assigned,"holds_assigned_objective":start==assigned and not observed.objective_at(assigned).is_empty(),"legal_attacks":attacks,"progress_to_enemy_objectives":progress})
		var before_serial=int(e.state.get("support_serial",0))
		check(dispatch(e,d),"actual recorded command accepted")
		for event in e.state.get("support_events",[]):
			if int(event.serial)>before_serial and event.kind=="surrender":surrenders.append(event.duplicate(true))
		if int(action.turn)==11 and int(action.side)==1 and d.kind=="end":
			var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json")
			var save=Save.new("user://full_turn12.json",raw.sha256_text())
			check(e.state.turn==12 and e.state.side==0 and save.save_game(e),"chronological turn 12 checkpoint saved")
			var copy=Rules.new(p);check(save.load_game(copy) and copy.validate(copy.state),"chronological turn 12 checkpoint reload")
			check(JSON.parse_string(JSON.stringify(copy.state))==JSON.parse_string(JSON.stringify(e.state)),"chronological turn 12 exact reload")
	check(e.state.finished and e.validate(e.state),"full replay finished and valid")
	check(FullBattle.scheduled_reinforcements_consistent(e),"reinforcements correctly wait at occupied entry")
	var expected=report.final.duplicate(true);expected.erase("pending")
	check(JSON.parse_string(JSON.stringify(metrics(e)))==expected,"deterministic full final replay")
	var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json")
	var saved=Rules.new(p);var final_store=Save.new("res://tests/results/0837/full_final_save.json",raw.sha256_text())
	check(final_store.load_game(saved),"actual final saved battle loads")
	check(JSON.parse_string(JSON.stringify(saved.state))==JSON.parse_string(JSON.stringify(e.state)),"replay reproduces entire final saved state")
	for n in range(e.state.units.size()):
		var u=e.state.units[n]
		if u.get("pending",false):awaiting.append({"unit":u.id,"arrival_turn":u.arrival_turn,"cell":u.cell,"occupant_index":e.unit_at(e.unit_cell(u))})
	check(surrenders.size()==int(e.state.get("surrender_serial",0)),"all surrender events accounted for")
	var output={"inactive_with_observed_opportunity":idle,"pending_reinforcements":awaiting,"surrender_events":surrenders,"note":"Only authorized observations examined. Legal progress is an opportunity proxy, not proof that a reserve should advance. Unit-turn observations may repeat the same unit."}
	var f=FileAccess.open("user://full_battle_analysis.json",FileAccess.WRITE);f.store_string(JSON.stringify(output,"\t"));f.close()
	print("V37 FULL REPLAY ",checks-failures,"/",checks," opportunity observations=",idle.size());quit(1 if failures else 0)
