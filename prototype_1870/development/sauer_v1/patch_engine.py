from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=root/'war_engine/core/rules_base.gd';s=p.read_text()
s=s.replace('var height: int','var height: int\nvar river_links: Dictionary={}')
s=s.replace('pack=data.duplicate(true);width=int(pack.map.width);height=int(pack.map.height);new_game()','pack=data.duplicate(true);width=int(pack.map.width);height=int(pack.map.height)\n\tfor edge in pack.map.get("river_edges",[]):river_links[river_key(int(edge.a),int(edge.b))]=bool(edge.get("bridge",false))\n\tnew_game()')
s=s.replace('u.deployed=false','u.deployed=false;u.river_halt=false',1)
s=s.replace('state.scores=[int(state.scores[0]),int(state.scores[1])]','state.scores=[int(state.scores[0]),int(state.scores[1])]')
s=s.replace('for u in state.units:\n\t\tfor f in ["side"','for u in state.units:\n\t\tu.river_halt=bool(u.get("river_halt",false))\n\t\tfor f in ["side"',1)
pos=s.index('func can_act(')
s=s[:pos]+'''func river_key(a: int,b: int) -> String:return "%d:%d"%[mini(a,b),maxi(a,b)]
func open_river(a: int,b: int) -> bool:
	var k=river_key(a,b)
	return river_links.has(k) and not bool(river_links[k])
func edge_allowed(n: int,a: int,b: int) -> bool:
	return not open_river(a,b) or (not artillery(n) and not (n>=0 and weapon(n).get("unit_type","")=="cavalry"))
func step_cost(n: int,a: int,b: int) -> int:
	if cost(b)<0 or not edge_allowed(n,a,b):return -1
	return movement_cost(n,b)+(int(pack.rules.get("river",{}).get("infantry_extra_ap",8)) if open_river(a,b) else 0)
func path_has_river(path: Array) -> bool:
	for k in range(1,path.size()):
		if open_river(int(path[k-1]),int(path[k])):return true
	return false
''' +s[pos:]
s=s.replace('if not can_act(n) or state.units[n].deployed:return','if not can_act(n) or state.units[n].deployed or state.units[n].get("river_halt",false):return',1)
s=s.replace('var total=int(costs[current])+movement_cost(n,next)','var step=step_cost(n,current,next)\n\t\t\tif step<0 or (open_river(current,next) and occupied>=0):continue\n\t\t\tvar total=int(costs[current])+step\n\t\t\t# A ford consumes the remaining movement budget, not the remaining action points.\n\t\t\tif not unlimited and open_river(current,next) and total<=budget:total=budget',1)
s=s.replace('total+=movement_cost(n,full[k])','total+=step_cost(n,int(full[k-1]),int(full[k]))',1)
s=s.replace('if path_unit_at(full[k])<0:last=k','if path_unit_at(full[k])<0:last=k\n\t\tif open_river(int(full[k-1]),int(full[k])):break',1)
s=s.replace('result+=movement_cost(n,int(path[j]))','result+=step_cost(n,int(path[j-1]),int(path[j]))',1)
s=s.replace('if state.units[n].deployed:return "deployed"','if state.units[n].deployed:return "deployed"\n\tif state.units[n].get("river_halt",false):return "river_halt"',1)
s=s.replace('total+=movement_cost(n,next)','var step=step_cost(n,int(path[j-1]),next)\n\t\tif step<0 or (open_river(int(path[j-1]),next) and j<path.size()-1):return "river"\n\t\ttotal+=step',1)
s=s.replace('var dest=cell(int(path[-1]));u.cell=[dest.x,dest.y];u.ap=int(u.ap)-total','var dest=cell(int(path[-1]));u.cell=[dest.x,dest.y];u.ap=int(u.ap)-total\n\tu.river_halt=path_has_river(path)',1)
s=s.replace('return float(pack.terrains[pack.map.tiles[i]].get("elevation",0.0))','return float(pack.map.elevations[i]) if pack.map.has("elevations") else float(pack.terrains[pack.map.tiles[i]].get("elevation",0.0))',1)
p.write_text(s)
p=root/'war_engine/core/engine.gd';s=p.read_text()
s=s.replace('super.new_game();state.human_side=human;state.assaults=0','super.new_game();state.human_side=human;state.assaults=0\n\tstate.owner=int(pack.get("initial_owner",-1))',1)
s=s.replace('if u.deployed:return "deployed"','if u.deployed:return "deployed"\n\tif u.get("river_halt",false):return "river_halt"',1)
s=s.replace('total+=movement_cost(n,next)','var step=step_cost(n,int(path[k-1]),next)\n\t\tif step<0 or (open_river(int(path[k-1]),next) and k<path.size()-1):return "river"\n\t\tif open_river(int(path[k-1]),next) and known>=0:return "occupied"\n\t\ttotal+=step',1)
s=s.replace('pending_cost+=movement_cost(n,next)','pending_cost+=step_cost(n,int(path[k-1]),next)',1)
s=s.replace('u.cell=[cell(next).x,cell(next).y];u.ap-=pending_cost;pending_cost=0;travelled+=1;u.entrenched=false','u.cell=[cell(next).x,cell(next).y];u.ap-=pending_cost;pending_cost=0;travelled+=1;u.entrenched=false\n\t\tif open_river(int(path[k-1]),next):u.river_halt=true',1)
s=s.replace('if distance(unit_cell(a),unit_cell(b))!=1:return "range"','if distance(unit_cell(a),unit_cell(b))!=1:return "range"\n\tif a.get("river_halt",false) or open_river(unit_cell(a),unit_cell(b)):return "river"',1)
s=s.replace('if paths.has(next) or cost(next)<0:continue','if paths.has(next) or cost(next)<0 or not edge_allowed(n,current,next):continue',1)
s=s.replace('paths[next]=path+[next];open.append(next)','if open_river(current,next) and occupant>=0:continue\n\t\t\tpaths[next]=path+[next]\n\t\t\tif not open_river(current,next):open.append(next)',1)
s=s.replace('u.rallied=false\n\t\tvar resupply_ready','u.rallied=false;u.river_halt=false\n\t\tvar resupply_ready',1)
s=s.replace('"command_group","attacked","supply_interrupted"]','"command_group","attacked","supply_interrupted","river_halt"]',1)
s=s.replace('for u in s.units:\n\t\tfor key','for u in s.units:\n\t\tif u.has("river_halt") and not u.river_halt is bool:return false\n\t\tfor key',1)
p.write_text(s)
# Path potential must be specific to the unit, so mounted troops seek the bridge.
p=root/'war_engine/ai/legacy_ai.gd';s=p.read_text().replace('var weights=e.pack.ai;var goal=e.objective();var field=goal_distances(e,goal)','var weights=e.pack.ai;var goal=e.objective()').replace('var u=e.state.units[n];var start=e.unit_cell(u)','var u=e.state.units[n];var start=e.unit_cell(u);var field=goal_distances(e,goal,n)',1).replace('func goal_distances(e,goal: int) -> Dictionary:','func goal_distances(e,goal: int,n: int=-1) -> Dictionary:').replace('var total=int(costs[current])+maxi(1,e.cost(current))','var step=e.step_cost(n,next,current)\n\t\t\tif step<0:continue\n\t\t\tvar total=int(costs[current])+maxi(1,step)');p.write_text(s)
p=root/'war_engine/ai/tactical_ai.gd';s=p.read_text().replace('var goal=e.objective();var field=Legacy.new().goal_distances(e,goal)','var goal=e.objective();var fields={}')
s=s.replace('var u=e.state.units[n];var start=e.unit_cell(u)','var u=e.state.units[n];var start=e.unit_cell(u)\n\t\tvar field_key=str(u.weapon)+"/"+e.formation(n)\n\t\tif not fields.has(field_key):fields[field_key]=Legacy.new().goal_distances(e,goal,n)\n\t\tvar field=fields[field_key]',1);p.write_text(s)
# Rear is west/east (rows) in this rotated sector, with explicit data fallback for old games.
p=root/'war_engine/core/support.gd';s=p.read_text().replace('var rear=[];var edge=int(cfg.rear_columns[side])\n\tfor row in range(e.height):rear.append(e.index(Vector2i(edge,row)))','var rear=[]\n\tif cfg.has("rear_rows"):\n\t\tfor col in range(e.width):rear.append(e.index(Vector2i(col,int(cfg.rear_rows[side]))))\n\telse:\n\t\tvar edge=int(cfg.rear_columns[side])\n\t\tfor row in range(e.height):rear.append(e.index(Vector2i(edge,row)))');p.write_text(s)
