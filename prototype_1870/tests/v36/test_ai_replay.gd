extends "res://tests/v36/test_ai_active.gd"
# Replay actual decisions to measure legal, observed tactical opportunities at end.
func _initialize():
	for label in ["AB_active","C_turn12","E_final"]:
		var report=JSON.parse_string(FileAccess.get_file_as_string("res://tests/results/0836/"+label+".json"))
		var e=Rules.new(scenario());e.new_game(0,report.difficulty);e.state.seed=int(report.seed);e.state.turn=int(report.start_turn);e.state.ai_style=0
		if report.start_turn>1:
			e.state.owner=0;e.state.objective_owners={"froeschwiller":0,"elsasshausen":1,"niederwald":0};e.state.units[8].cell=[15,4];e.state.units[1].cell=[16,3]
			for n in [0,3,7,9]:
				var u=e.state.units[n];u.casualties=roundi(u.initial_strength*0.3);u.strength=u.initial_strength-u.casualties;u.cohesion=55;u.morale="shaken";u.ammo_level=1
			e.refresh_support();e.refresh_intel()
		var idle=[];var rout_max=[0,0];var tactical_actions=[];var diagnosis=AI.new()
		for action in report.actions:
			var d=action.decision
			if d.kind=="end":
				var view=e.observation(int(e.state.side));var observed=Rules.new(view.pack,view.state)
				for n in range(observed.state.units.size()):
					if not observed.can_act(n) or observed.headquarters(n) or observed.state.units[n].morale=="routed":continue
					var legal_attacks=[];var progresses=[];var start=observed.unit_cell(observed.state.units[n]);var reachable=observed.reach(n).costs
					diagnosis.offensive=int(observed.pack.ai.get("attacking_side",-1))==int(observed.state.side)
					var assigned=diagnosis.mission_goal(observed,n,{})
					for j in range(observed.state.units.size()):
						if observed.fire_status(n,j)=="ok" or observed.assault_status(n,j)=="ok":legal_attacks.append(observed.state.units[j].id)
					for goal in observed.objective_definitions():
						if observed.objective_owner(goal)==int(e.state.side):continue
						var pos=observed.objective_cell(goal);var distance=observed.distance(start,pos)
						for dest in reachable:
							if observed.distance(int(dest),pos)<distance:progresses.append(goal.id);break
					if not legal_attacks.is_empty() or not progresses.is_empty():idle.append({"turn":e.state.turn,"side":e.state.side,"unit":observed.state.units[n].id,"ap":observed.state.units[n].ap,"cell":observed.state.units[n].cell,"assigned_goal":assigned,"holds_assigned_objective":start==assigned and not observed.objective_at(assigned).is_empty(),"legal_attacks":legal_attacks,"progress_to_enemy_objectives":progresses})
			check(dispatch(e,d),label+" recorded command accepted")
			for side in [0,1]:rout_max[side]=maxi(rout_max[side],e.routed_count(side))
			if d.kind in ["fire","assault"]:tactical_actions.append({"turn":action.turn,"side":action.side,"kind":d.kind,"unit":d.unit,"target":d.target})
		check(e.validate(e.state),label+" replay final validates")
		check(JSON.parse_string(JSON.stringify(metrics(e)))==report.final,label+" deterministic final replay")
		var output={"label":label,"inactive_with_observed_opportunity":idle,"max_routed_during_battle":rout_max,"tactical_actions":tactical_actions,"note":"Legal movement toward an enemy objective is an opportunity proxy, not proof that a reserve should advance. Only sanitized observations were examined."}
		var f=FileAccess.open("user://"+label+"_analysis.json",FileAccess.WRITE);f.store_string(JSON.stringify(output,"\t"));f.close()
		print(label," inactivity opportunities ",idle.size()," max routed ",rout_max)
	print("V36 AI REPLAY ",checks-failures,"/",checks);quit(1 if failures else 0)
