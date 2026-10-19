extends "res://tests/test_river0814.gd"
func _initialize():
	data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/prototype.json"))
	for side in [0,1]:
		var n=0 if side==0 else 4
		for attack in [false,true]:
			var e=Rules.new(data);e.state.side=side
			e.state.units[n].ammo_level=2;e.state.units[n].attacked=attack
			e.end_side();e.end_side()
			check(e.state.units[n].ammo_level==(2 if attack else 1),"automatic supply without rest, camp "+str(side)+", attack "+str(attack))
		var e=Rules.new(data);e.state.side=side;e.state.units[n].ammo_level=2
		var paths=e.reach(n).costs;var dest=-1
		for i in paths:
			if int(i)!=e.unit_cell(e.state.units[n]) and e.unit_at(int(i))<0:dest=int(i);break
		check(dest>=0 and e.move(n,e.path_to(n,dest)) in ["moved","discovered","capture"],"actual movement before supply")
		e.end_side();e.end_side()
		check(e.state.units[n].ammo_level==1,"movement allows automatic resupply")
	print("SUPPLY 0817: %d/%d passed"%[checks-failures,checks]);quit(1 if failures else 0)
