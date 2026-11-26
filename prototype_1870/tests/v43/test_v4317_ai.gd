extends "res://tests/test_ai_compat0833.gd"
const Frozen=preload("res://war_engine/ai/v4316_ai.gd")
func small(ids: Array,cells: Array):
 var p=data.duplicate(true);p.units=[];p.rules.fog.enabled=false;p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[]
 for id in ids:
  for u in data.units:
   if u.id==id:p.units.append(u.duplicate(true))
 for n in range(ids.size()):p.units[n].cell=cells[n];p.units[n].arrival_turn=1
 var e=Rules.new(p);e.new_game(1,"hard");e.state.seed=918536;e.state.ai_style=1;e.state.side=0
 for n in range(e.state.units.size()):
  e.state.units[n].formation="none" if e.artillery(n) or e.cavalry(n) else "line"
  if n>0 and e.state.units[n].side==0:e.state.units[n].done=true
 return e
func observed(e):
 var seen=[]
 for n in range(e.state.units.size()):
  if e.state.units[n].side==1:seen.append(n)
 return e.observation(0,seen)
func _initialize():
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=small(["art_fr_Pellé0","fr_7","pru_36","qg_fr_Pellé"],[[10,5],[11,5],[10,10],[9,2]])
 e.state.units[0].deployed=true;e.state.units[1].done=false;e.state.units[1].formation="column"
 var view=observed(e);var before=view.duplicate(true);var a=bot().choose(view)
 print("GUN FIRST ",JSON.stringify(a));check(a.kind=="fire" and a.unit=="art_fr_Pellé0" and dispatch(e,a),"real ready cannon fires before ordinary infantry preparation")
 check(view==before and e.state.units[0].ap==4 and e.state.events[-1].cannon,"priority respects observation and exact three PA firing cost")
 view=e.observation(0,[]);a=bot().choose(view);check(a.kind!="fire","hidden targets never create an artillery order")
 e=small(["art_fr_Pellé0","pru_36"],[[10,5],[10,10]])
 e.state.units[0].turn_ap_limit=12;e.state.units[0].ap=12
 check(not e.state.units[0].command_ok and e.state.units[0].supply_ok,"three PA gun fixture lacks command but retains supply")
 a=bot().choose(observed(e));print("DEPLOY THREE ",JSON.stringify(a))
 check(a.kind=="deploy" and dispatch(e,a) and e.state.units[0].ap==8,"three PA battery deploys now without a free shot")
 check(e.fire_status(0,1)=="no_ap","deployment leaves insufficient AP for the three PA shot")
 e.end_side();e.end_side();a=bot().choose(observed(e))
 check(a.kind=="fire" and a.unit=="art_fr_Pellé0" and dispatch(e,a) and e.state.units[0].ap==0,"deployed three PA battery really fires at the following turn")
 e=small(["art_fr_Pellé0","fr_7","pru_36","qg_fr_Pellé"],[[11,5],[11,7],[11,10],[10,2]])
 check(e.fire_status(0,2)!="ok","stationary objective gun has a blocked lane")
 var ai=bot();a=ai.choose(observed(e));print("BLOCKED GUN ",JSON.stringify(a))
 check(a.kind=="move" and a.unit=="art_fr_Pellé0" and dispatch(e,a),"silent gun leaves objective lock for an actual legal firing lane")
 var fired=false
 for step in range(20):
  a=ai.choose(observed(e));check(dispatch(e,a) and e.validate(e.state),"battery cycle is a legal native order")
  if a.kind=="fire" and a.unit=="art_fr_Pellé0":fired=true;break
  if a.kind=="end":e.end_side()
 check(fired,"relocated battery eventually contributes an actual cannon shot")
 e=small(["fr_9","pru_36","qg_fr_Pellé"],[[10,6],[10,12],[10,2]])
 e.pack.map.tiles[e.unit_cell(e.state.units[0])]="forest";a=bot().choose(observed(e));print("PREPARE ",JSON.stringify(a))
 check(a.kind=="entrench" and dispatch(e,a) and e.state.units[0].ap==8,"defensive forest is prepared before enemy reaches rifle range")
 e=small(["fr_8","fr_7","fr_9","fr_10","qg_fr_Pellé","pru_54"],[[12,5],[11,5],[13,10],[18,6],[11,2],[13,4]])
 ai=bot();view=observed(e);a=ai.choose(view);print("COUNTER ",JSON.stringify(a))
 check(ai.defence.guards.size()==1,"one strong reserve suffices against a small observed raider")
 check(a.kind=="assault" and a.unit=="fr_8" and dispatch(e,a),"strong nearby reserve counterattacks a rear raider through existing assault rules")
 check(e.state.units[1].cell==[11,5] and e.state.units[2].cell==[13,10] and e.state.units[3].cell==[18,6],"first objective garrisons are not stripped for interception")
 e=small(["fr_10","qg_fr_Raoult"],[[18,6],[15,2]])
 view=observed(e);view.state.units[0].command_ok=false;view.state.units[0].supply_ok=false;view.state.units[0].isolation_turns=1;view.state.units[0].ap=8;view.state.units[0].turn_ap_limit=8;view.state.units[0].ammo_level=2
 a=bot().choose(view);check(a.kind=="move","secondary strongpoint starts a legal fallback at the first double-cut count")
 # Same observed world: no extra intelligence, no unit stat or ammunition bonus.
 var world=Rules.new(data);world.new_game(1,"hard");world.state.seed=918536;world.state.ai_style=1
 var twin=Rules.new(data);twin.state=world.state.duplicate(true);var hidden=twin.unit_index("pru_55");twin.state.units[hidden].cell=[29,19];twin.refresh_intel();world.refresh_intel()
 var original=world.state.duplicate(true)
 check(world.observation(0)==twin.observation(0) and bot().choose(world.observation(0))==bot().choose(twin.observation(0)),"Hard cannon/reserve planner cannot access hidden enemy positions")
 check(world.state==original,"planning never grants strength/AP/ammo or changes the live world")
 print("V43.17 FRENCH HARD ",checks-failures,"/",checks);quit(1 if failures else 0)
