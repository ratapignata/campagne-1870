extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL "+label)
func _initialize():
	var texts=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/fr.json"))
	for name in ["regimental_trial","prototype","three_objectives"]:
		var p=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/"+name+".json"));var before=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/legacy0830_"+name+".json"))
		var e=Rules.new(p);var old=Rules.new(before);var horse=-1
		for n in range(e.state.units.size()):
			if e.cavalry(n):horse=n
		check(e.vision_cache==old.vision_cache,"visibility and concealment unchanged "+name)
		for i in range(e.width*e.height):
			var t=p.terrains[p.map.tiles[i]];var previous=before.terrains[before.map.tiles[i]]
			if e.elevation(i)>=2 and e.cost(i)>=0:check(t.get("height_category",false) and texts["terrain_short_"+p.map.tiles[i]]=="Hauteur","height has one name")
			for key in ["cost","fire_received","blocks_fire","obstacle_height","assault_defence"]:check(t.get(key)==previous.get(key),"terrain mechanics preserved")
			check(e.movement_cost(horse,i)==old.movement_cost(horse,i),"cavalry movement preserved")
			check(e.movement_cost(0,i)==old.movement_cost(0,i),"infantry movement preserved")
		check(p.map.get("road_edges")==before.map.get("road_edges") and p.map.get("river_edges")==before.map.get("river_edges"),"roads and bridges preserved")
		check(p.weapons==before.weapons,"all weapon parameters preserved")
		# Sample firing lines across terrain categories with the same known units.
		for a in range(0,e.width*e.height,17):
			for b in range(0,e.width*e.height,19):check(e.line_status(a,b)==old.line_status(a,b),"line rules preserved")
	print("HEIGHT 0831 ",checks-failures,"/",checks);quit(1 if failures else 0)
