extends "res://tests/test_ai_compat0833.gd"
const Prior=preload("res://tests/v43/reference_ai_v4314.gd")
func small(ids: Array,cells: Array):
 var p=data.duplicate(true);p.units=[];p.rules.fog.enabled=false;p.rules.support.enabled=false;p.map.river_edges=[];p.map.tiles.fill("plain");p.map.elevations.fill(0)
 for id in ids:
  for u in data.units:
   if u.id==id:p.units.append(u.duplicate(true))
 for k in range(p.units.size()):p.units[k].arrival_turn=1;p.units[k].cell=cells[k]
 var e=Rules.new(p);e.new_game(1,"hard");e.state.turn=6;e.state.side=0;e.state.seed=18704315;e.state.ai_style=0
 for n in range(1,e.state.units.size()):e.state.units[n].done=true
 return e
func old_bot():
 var b=Prior.new();b.profiles=profiles;return b
func _initialize():
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=small(["fr_8","fr_7","pru_36","pru_37"],[[10,5],[11,5],[11,8],[13,8]])
 e.pack.map.tiles[e.index(Vector2i(11,5))]="village";e.pack.map.tiles[e.index(Vector2i(10,6))]="forest";e.state.units[0].formation="line"
 var view=e.observation(0,[2,3]);var original=view.duplicate(true);var old=old_bot();var ai=bot();var a=old.choose(view);var b=ai.choose(view)
 print("COVER ",JSON.stringify(a)," -> ",JSON.stringify(b))
 check(view==original,"French planner leaves sanitized observation intact")
 check(b.kind=="move" and e.pack.map.tiles[int(b.path[-1])]=="forest","French reinforcement takes protected firing position")
 check(dispatch(e,b) and int(e.state.units[0].ap)>=int(e.weapon(0).ap),"covered approach legal and leaves AP for rifle volley")
 b=ai.choose(e.observation(0,[2,3]));print("COVER FOLLOW ",JSON.stringify(b))
 check(b.kind=="entrench" and dispatch(e,b) and e.state.units[0].entrenched,"covered reinforcement prepares entrenchment before enemy assault")
 e.end_side();e.end_side();e.state.units[1].done=true
 b=ai.choose(e.observation(0,[2,3]));check(b.kind=="fire" and dispatch(e,b),"prepared reinforcement really fires at next activation")
 # Marching infantry must form a defensive line before shooting from cover.
 e=small(["fr_7","pru_36"],[[11,5],[11,8]]);e.pack.map.tiles[e.index(Vector2i(11,5))]="village"
 b=bot().choose(e.observation(0,[1]));check(b.kind=="formation" and b.formation=="line" and dispatch(e,b),"column forms line before firing under threat")
 b=bot().choose(e.observation(0,[1]));check(b.kind=="entrench" and dispatch(e,b),"threatened village garrison fortifies after forming line")
 check(e.state.units[0].ap==4,"formation and entrenchment consume their real existing AP")
 # A deployed French gun with a legal future shot keeps its safe position.
 e=small(["art_fr_Pellé0","pru_36"],[[10,5],[10,9]]);e.state.units[0].deployed=true;e.state.units[0].entrenched=true;e.state.units[0].ap=8
 e.pack.map.tiles[e.index(Vector2i(11,5))]="village";view=e.observation(0,[1]);a=old_bot().choose(view);b=bot().choose(view);print("BATTERY ",JSON.stringify(a)," -> ",JSON.stringify(b))
 check(a.kind=="limber","baseline wastes activation limbering useful French battery")
 check(b.kind=="end","useful safe French battery waits for next legal shot")
 e.state.units[0].ap=16;b=bot().choose(e.observation(0,[1]));check(b.kind=="fire" and dispatch(e,b),"French gun fires with enough AP, unchanged 3 AP cost")
 check(e.state.units[0].ap==4,"French artillery retains exact existing firing cost")
 # Controlled objective garrison fires without abandoning the strongpoint.
 e=small(["fr_7","pru_36"],[[11,5],[11,6]]);e.state.units[1].strength=250;e.state.units[1].casualties=e.state.units[1].initial_strength-250;e.state.units[1].morale="shaken"
 e.pack.map.tiles[e.index(Vector2i(11,5))]="village";e.state.units[0].entrenched=true;e.state.units[0].formation="line";b=bot().choose(e.observation(0,[1]))
 check(b.kind=="fire" and dispatch(e,b),"garrison fires from entrenchment rather than chase weak attacker")
 check(e.state.units[0].cell==[11,5] and e.state.units[0].entrenched,"strongpoint and protection retained")
 # Favorable local counterattack against a freshly lost objective.
 e=small(["fr_9","pru_36"],[[13,9],[13,10]]);e.state.objective_owners.elsasshausen=1;e.state.units[0].formation="line";e.state.units[1].strength=350;e.state.units[1].casualties=e.state.units[1].initial_strength-350
 b=bot().choose(e.observation(0,[1]));print("COUNTERATTACK ",JSON.stringify(b))
 check(b.kind=="assault" and dispatch(e,b),"favorable recapture launches a real legal assault")
 check(e.state.objective_owners.elsasshausen==0,"counterattack actually recaptures Woerth")
 # An outnumbered defender must not receive a combat bonus or make a hopeless assault.
 e=small(["fr_7","pru_36","pru_37"],[[13,9],[13,10],[14,10]]);e.state.units[0].strength=200;e.state.units[0].casualties=e.state.units[0].initial_strength-200;e.state.objective_owners.elsasshausen=1
 var before=e.pack.duplicate(true);view=e.observation(0,[1,2]);original=view.duplicate(true);b=bot().choose(view)
 check(b.kind!="assault" and dispatch(e,b),"weak defender avoids suicidal counterattack")
 check(e.pack==before and view==original,"planning adds no military power or AP")
 # Real initial full scenario: sectors and reserve allocation from own units/public goals.
 e=Rules.new(data);e.new_game(1,"hard");e.state.seed=18704315;e.state.ai_style=0;ai=bot();view=e.observation(0);b=ai.choose(view)
 check(ai.hard_defensive and ai.defence!=null and dispatch(e,b) and e.validate(e.state),"real 95-unit scenario starts with legal defensive decision")
 var held={}
 for anchor in ai.defence.assignments.values():held[int(anchor)]=true
 check(held.size()==3,"initial infantry and support assigned across all three objectives")
 print("SECTORS ",JSON.stringify(ai.defence.assignments)," RESERVES ",JSON.stringify(ai.defence.reserves))
 check(ai.defence.reserves.values().has(true),"some infantry retained as reserves away from observed threat")
 var threatened=Rules.new(data);threatened.new_game(1,"hard");threatened.pack.rules.fog.enabled=false;threatened.state.ai_style=0
 var enemy=threatened.unit_index("pru_36");threatened.state.units[enemy].cell=[11,8];ai=bot();ai.choose(threatened.observation(0,[enemy]));var reserved_front=false
 for k in ai.defence.reserves:
  if ai.defence.goal(int(k))==threatened.index(Vector2i(11,5)) and ai.defence.reserves[k]:reserved_front=true
 check(not reserved_front,"reserve released when observed enemy reaches defended sector")

 # Other policies must be precisely preserved on the same observations.
 for side in [0,1]:
  for mode in ["medium","hard"]:
   if side==0 and mode=="hard":continue
   var world=Rules.new(data);world.new_game(1,mode);world.state.seed=18704315;world.state.ai_style=0;world.state.side=side;world.refresh_intel();view=world.observation(side)
   check(bot().choose(view)==old_bot().choose(view),"V43.14 policy unchanged side %d mode %s"%[side,mode])
 # Save/reload has no new mandatory AI state or hidden information.
 e=Rules.new(data);e.new_game(1,"hard");var store=Store.new("user://v4315.json","v4315");var resumed=Rules.new(data)
 check(store.save_game(e) and store.load_game(resumed) and resumed.state==e.state,"Prussian human/French AI save roundtrip")
 var twin=Rules.new(data);twin.state=e.state.duplicate(true);var hidden=e.unit_index("pru_55");twin.state.units[hidden].cell=[29,19];twin.refresh_intel();e.refresh_intel()
 check(not e.visible_to(0,hidden) and not twin.visible_to(0,hidden),"two worlds keep Prussian scout hidden")
 check(e.observation(0)==twin.observation(0) and bot().choose(e.observation(0))==bot().choose(twin.observation(0)),"French defence does not use hidden Prussian positions")
 print("V43.15 DEFENCE ",checks-failures,"/",checks);quit(1 if failures else 0)
