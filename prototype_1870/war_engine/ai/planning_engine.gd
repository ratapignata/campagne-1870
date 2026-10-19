extends "res://war_engine/core/engine.gd"
# Short-lived AI observation only. Combat and live game state never use this cache.
# All hypothetical cell changes in tactical_ai pass through set_planning_cell.
static var distance_tables: Dictionary={}
var planning_distance_rows: Dictionary={}
var planning_cell_count=0
var planning_occupants: Dictionary={}
var planning_cache_ready=false
func _init(data: Dictionary,initial_state: Dictionary={}) -> void:
	super(data,initial_state)
	for n in range(state.units.size()):
		if alive(n):planning_occupants[unit_cell(state.units[n])]=n
	planning_cell_count=width*height
	var geometry=str(width)+"/"+str(height)
	if not distance_tables.has(geometry):distance_tables[geometry]={}
	planning_distance_rows=distance_tables[geometry]
	planning_cache_ready=true
func unit_at(i: int) -> int:
	return int(planning_occupants.get(i,-1)) if planning_cache_ready else super.unit_at(i)
func set_planning_cell(n: int,position: Array) -> void:
	var old=unit_cell(state.units[n])
	if planning_occupants.get(old,-1)==n:planning_occupants.erase(old)
	state.units[n].cell=position
	if alive(n):planning_occupants[unit_cell(state.units[n])]=n

func distance(a: int,b: int) -> int:
	# Hex distance depends only on map dimensions, never on units or terrain.
	if not planning_cache_ready or a<0 or b<0 or a>=planning_cell_count or b>=planning_cell_count:return super.distance(a,b)
	if not planning_distance_rows.has(a):
		var row=PackedInt32Array();row.resize(planning_cell_count)
		for destination in range(planning_cell_count):row[destination]=super.distance(a,destination)
		planning_distance_rows[a]=row
	return int(planning_distance_rows[a][b])
