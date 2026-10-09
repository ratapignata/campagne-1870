extends "res://tests/test_strict0833.gd"
func _initialize():
	var e=fresh();wall(e,19)
	for turn in range(1,4):
		e.end_side();e.end_side()
		check(int(e.state.units[cav].get("isolation_turns",0))==turn,"persistent isolation count "+str(turn))
		if turn==1:check(e.alive(cav) and e.state.units[cav].morale=="stable","one turn grace")
		if turn==2:check(e.alive(cav) and e.state.units[cav].morale=="shaken","second turn disorganised without quiet recovery")
	check(e.alive(cav) and e.state.units[cav].morale=="routed" and e.state.units[cav].cell!=[10,6],"third turn retreats through the open northern rear")
	check(e.validate(e.state),"surrender state valid")
	e=fresh();wall(e,19);e.end_side();e.end_side()
	var copy=Rules.new(e.pack);copy.state=JSON.parse_string(JSON.stringify(e.state));copy.normalize()
	check(copy.validate(copy.state) and int(copy.state.units[cav].isolation_turns)==1,"isolation countdown saved")
	e.state.units[cav].cell=[4,6];e.refresh_support();check(e.state.units[cav].isolation_turns==0,"reconnection resets countdown immediately")
	print("ISOLATION 0835 ",checks-failures,"/",checks);quit(1 if failures else 0)
