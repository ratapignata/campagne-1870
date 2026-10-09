extends "res://tests/test_ai_compat0833.gd"
func _initialize():
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial.json"));var roster=[]
	for pair in [[0,[15,4],1],[56,[13,3],1],[58,[15,4],3],[34,[25,15],1],[66,[27,15],1]]:
		var u=p.units[pair[0]].duplicate(true);u.cell=pair[1];u.arrival_turn=pair[2];u.command_group="fr_Ducrot" if u.side==0 else "pr_Sandrart";roster.append(u)
	p.units=roster;var e=Rules.new(p);e.new_game(0,"hard");e.state.turn=2;e.state.ai_style=0
	for u in e.state.units:
		if not u.pending:u.formation="line"
	e.refresh_support();e.refresh_intel();var ai=bot();var moved=false;var actions=[]
	for step in range(20):
		if e.state.side!=0:break
		var d=ai.choose(e.observation(0));actions.append(d);check(dispatch(e,d),"entry clearance action legal")
		if e.unit_cell(e.state.units[0])!=e.unit_cell(e.state.units[2]):moved=true;break
	check(moved,"hard clears safely occupied incoming entry, including own objective garrison")
	check(e.state.units[2].pending and int(e.state.units[2].strength)==0,"reinforcement never enters before its legal arrival")
	while e.state.side==0:e.end_side()
	e.end_side();check(not e.state.units[2].pending and e.state.turn==3,"scheduled reinforcement enters original cell on actual turn three")
	check(e.validate(e.state),"clearance and arrival preserve validated state")
	print("V38 REINFORCEMENTS ",checks-failures,"/",checks," actions ",JSON.stringify(actions));quit(1 if failures else 0)
