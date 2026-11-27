extends "res://tests/test_ai_compat0833.gd"
const Frozen=preload("res://war_engine/ai/v4317_ai.gd")
func sample(mode: String="hard",human: int=1):
 var p=data.duplicate(true);p.rules.support.enabled=false;p.rules.fog.enabled=false;p.map.tiles.fill("plain");p.map.elevations.fill(0);p.map.river_edges=[];p.units=[]
 for id in ["fr_9","pru_36"]:
  for u in data.units:
   if u.id==id:p.units.append(u.duplicate(true))
 p.units[0].cell=[10,10];p.units[1].cell=[10,14]
 for u in p.units:u.arrival_turn=1
 var e=Rules.new(p);e.new_game(human,mode);e.state.side=0;e.state.ai_style=1;e.state.seed=918536
 for u in e.state.units:u.formation="line"
 return e
func _initialize():
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 for mode in ["medium","hard"]:
  for human in [0,1]:
   var e=sample(mode,human)
   check(e.distance(e.unit_cell(e.state.units[0]),e.unit_cell(e.state.units[1]))==4,"exact four-hex fixture")
   check(e.weapon(0).range==4 and e.weapon(1).range==2 and e.weapon(0).ap==8,"same rifle ranges/cost in both modes and both human camps")
   check(e.fire_status(0,1)=="ok","visible unobstructed target legal at four hexes")
   var before=int(e.state.units[0].ap);var hit=e.fire(0,1)
   check(hit.status=="ok" and e.state.units[0].ap==before-8,"real four-hex fire uses exactly two PA")
 var e=sample();e.state.side=1
 check(e.reaction_status(0,1)=="range","Chassepot cannot react at four hexes")
 e.state.units[1].cell=[10,13];check(e.reaction_status(0,1)=="ok","existing three-hex reaction retained")
 e=sample();e.weapon(0).variance=0.0
 var at_four=e.shot_loss(0,1,RandomNumberGenerator.new());e.state.units[1].cell=[10,13];var at_three=e.shot_loss(0,1,RandomNumberGenerator.new())
 check(at_four>0 and at_four<at_three,"fourth distance band remains weaker than third")
 # Policy equality with the exact V43.16 controller, given the shared new rules.
 e=sample("medium");e.state.units[1].cell=[10,12]
 var current=bot();var frozen=Frozen.new();frozen.profiles=profiles
 for step in range(6):
  var view=e.observation(int(e.state.side));view.state.ai_difficulty="medium";var old_view=view.duplicate(true);old_view.state.ai_difficulty="hard";var untouched=view.duplicate(true)
  var a=current.choose(view);var b=frozen.choose(old_view)
  check(a==b and current.relocation==frozen.relocation,"French Normal exactly retains V43.16 decision "+str(step))
  check(view==untouched and dispatch(e,a) and e.validate(e.state),"normal action legal and observation unchanged")
  if a.kind=="end":break
 var normal=Rules.new(data);normal.new_game(1,"medium");var hard=Rules.new(data);hard.new_game(1,"hard")
 for u in data.units:check(normal.reinforcement_turn(u)==hard.reinforcement_turn(u),"same calendar for Prussian player across French difficulty "+u.id)
 var prior_hash="5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57"
 var path="res://tests/graphics/fixtures/essai09_slot.json";var original=FileAccess.get_file_as_bytes(path)
 var store=Store.new(path,FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json").sha256_text(),data.save_migrations);var restored=Rules.new(data)
 check(data.save_migrations.has(prior_hash) and store.load_game(restored) and restored.validate(restored.state),"Graphisme12/V43.16 fingerprint explicitly supported")
 check(FileAccess.get_file_as_bytes(path)==original,"old save fixture unchanged")
 # A completed old save keeps its score and canonical numeric state through migration.
 var completed=Rules.new(data);completed.new_game(1,"hard");completed.state.turn=20;completed.state.side=1;completed.state.finished=true
 check(completed.validate(completed.state),"completed migration fixture is a valid native state")
 var payload=JSON.stringify({"state":completed.state,"previous":{}});var legacy_path="user://v4316_completed.json"
 var file=FileAccess.open(legacy_path,FileAccess.WRITE);file.store_string(JSON.stringify({"schema":1,"pack_hash":prior_hash,"payload":payload,"checksum":payload.sha256_text()}));file.close()
 var bytes=FileAccess.get_file_as_bytes(legacy_path);var migration=Store.new(legacy_path,FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json").sha256_text(),data.save_migrations)
 var migrated=Rules.new(data);check(migration.load_game(migrated),"actual loader migrates completed V43.16 fingerprint")
 check(migrated.state.completed_turn_limit is int and migrated.state.completed_turn_limit==20,"completed turn denominator normalized as integer")
 var current_slot=Store.new("user://v4317_completed_copy.json",migration.fingerprint);var reloaded=Rules.new(data)
 check(current_slot.save_game(migrated) and current_slot.load_game(reloaded),"completed migrated game really saves and reloads")
 check(reloaded.state==migrated.state and reloaded.result_for(1)==migrated.result_for(1),"full canonical state and completed score survive migration round trip")
 check(FileAccess.get_file_as_bytes(legacy_path)==bytes,"migration leaves original completed save intact")
 print("V43.17 RULES ",checks-failures,"/",checks);quit(1 if failures else 0)
