extends "res://tests/v43/test_raoult.gd"
func _initialize():call_deferred("run_adjacent")
func candidate():return JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"))
func arrival_fixture(friendly:bool=false):
 var p=candidate();var h=p.units[60].duplicate(true);var c=p.units[53 if not friendly else 24].duplicate(true)
 h.cell=[15,4];h.arrival_turn=3;c.cell=[15,4];c.arrival_turn=1;p.units=[h,c];p.rules.support.enabled=false;p.rules.fog.enabled=false;p.map.tiles.fill("plain");p.map.river_edges=[];p.map.road_edges=[]
 var e=Rules.new(p);e.new_game(0,"medium");e.state.turn=3;e.state.side=0;return e
func run_adjacent():
 # Reproduce exact legal T2 cavalry occupation from the existing baseline probe.
 var old=blocked();var e=Rules.new(candidate());e.state=old.state.duplicate(true);e.normalize();var h=e.unit_index("qg_fr_Raoult");var c=e.unit_index("pru_55");var origin=e.unit_cell(e.state.units[h]);var enemy=e.state.units[c].duplicate(true)
 check(e.state.turn==3 and e.state.side==0 and e.state.units[h].pending,"actual reproduced T3 arrival before rule applied")
 e.arrive_reinforcements();e.refresh_support();e.refresh_intel()
 check(e.alive(h) and not e.state.units[h].pending and e.distance(origin,e.unit_cell(e.state.units[h]))==1,"Raoult enters an adjacent hex at T3 despite enemy on original entry")
 check(e.unit_at(origin)==c and e.state.units[c]==enemy,"enemy not displaced or damaged")
 check(e.unit_at(e.unit_cell(e.state.units[h]))==h and e.visible_to(0,h) and e.validate(e.state),"one occupant per hex, HQ visible and state valid")
 check(int(e.state.units[h].initial_strength)==250 and int(e.state.units[h].strength)==250,"HQ full scheduled reinforcement strength")
 var arrived=e.state.units[h].cell.duplicate();var store=Store.new("user://adjacent_hq.json","adjacent-hq");var copy=Rules.new(e.pack)
 check(store.save_game(e) and store.load_game(copy) and copy.state.units[h].cell==arrived and not copy.state.units[h].pending,"actual adjacent HQ location persists across save/reload")
 var before=copy.state.units[h].duplicate(true);copy.arrive_reinforcements();check(copy.state.units[h]==before,"arrived reinforcement never respawns or shifts again")
 e=arrival_fixture();var hex=e.unit_cell(e.state.units[0]);e.state.turn=2;e.arrive_reinforcements();check(e.state.units[0].pending,"no early entry")
 e.state.turn=3;e.state.side=1;e.arrive_reinforcements();check(e.state.units[0].pending,"only own arrival phase")
 e.state.side=0;e.arrive_reinforcements();var first=e.state.units[0].cell.duplicate()
 var twin=arrival_fixture();twin.arrive_reinforcements();check(first==twin.state.units[0].cell,"deterministic adjacent choice")
 e=arrival_fixture(true);e.arrive_reinforcements();check(e.state.units[0].pending and e.state.units[0].cell==[15,4],"friendly-held entry retains existing wait rule")
 e=arrival_fixture();hex=e.unit_cell(e.state.units[0]);var adjacent=e.neighbours(hex).duplicate();adjacent.sort()
 for pos in adjacent:e.pack.map.tiles[pos]="water"
 e.arrive_reinforcements();check(e.state.units[0].pending and e.unit_cell(e.state.units[0])==hex,"no passable adjacent hex safely waits at original entry")
 e=arrival_fixture();var ring=e.pack.duplicate(true);hex=e.unit_cell(e.state.units[0])
 for pos in e.neighbours(hex):
  var block=ring.units[1].duplicate(true);block.id="ring_"+str(pos);block.cell=[e.cell(pos).x,e.cell(pos).y];block.arrival_turn=1;ring.units.append(block)
 e=Rules.new(ring);e.new_game(0,"medium");e.state.turn=3;e.state.side=0;e.arrive_reinforcements()
 check(e.state.units[0].pending and e.unit_cell(e.state.units[0])==hex and e.validate(e.state),"all adjacent hexes occupied safely keeps reinforcement waiting")
 # A cavalry reinforcement cannot replace an enemy-held entry with a water hex.
 e=arrival_fixture();e.pack.units[0].weapon="sabre";e.state.units[0].weapon="sabre";hex=e.unit_cell(e.state.units[0])
 for pos in e.neighbours(hex):e.pack.map.tiles[pos]="water"
 e.arrive_reinforcements();check(e.state.units[0].pending,"cavalry also respects impassable terrain")
 # The first legal candidate is separated by an unbridged river, so use the next.
 e=arrival_fixture();hex=e.unit_cell(e.state.units[0]);adjacent=e.neighbours(hex).duplicate();adjacent.sort();e.river_links[e.river_key(hex,adjacent[0])]=false
 e.arrive_reinforcements();check(e.unit_cell(e.state.units[0])==adjacent[1],"no arrival across an unbridged river")
 e=arrival_fixture();var mirrored=e.pack.duplicate(true)
 for u in mirrored.units:u.side=1-int(u.side)
 e=Rules.new(mirrored);e.new_game(1,"medium");e.state.turn=3;e.state.side=1;e.arrive_reinforcements()
 check(not e.state.units[0].pending and e.distance(e.index(Vector2i(15,4)),e.unit_cell(e.state.units[0]))==1 and e.validate(e.state),"same adjacent reinforcement rule for German camp")
 # Two incoming units cannot select the same fallback hex.
 e=arrival_fixture();var extra=e.pack.units[0].duplicate(true);extra.id="second_hq";e.pack.units.append(extra);e.new_game(0,"medium");e.state.turn=3;e.state.side=0;e.arrive_reinforcements()
 check(not e.state.units[0].pending and not e.state.units[2].pending and e.unit_cell(e.state.units[0])!=e.unit_cell(e.state.units[2]),"simultaneous reinforcements use separate unoccupied adjacent hexes")
 check(e.validate(e.state),"multiple arrivals validate")
 # A free original entry remains the preferred position.
 e=arrival_fixture();e.state.units[1].cell=[25,15];e.arrive_reinforcements();check(e.state.units[0].cell==[15,4] and not e.state.units[0].pending,"free original entry unchanged")
 # Physical migration of an already-blocked V43 save: new rule applies at next own phase.
 var old_raw=FileAccess.get_file_as_string("res://tests/v43/fixtures/v43_before_adjacent.json");var previous=Rules.new(JSON.parse_string(old_raw));previous.state=old.state.duplicate(true)
 var old_slot=Store.new("user://old_v43.json",old_raw.sha256_text());check(old_slot.save_game(previous),"actual V43 blocked save written with original fingerprint")
 var current_raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json");var current_pack=JSON.parse_string(current_raw);var migrated=Rules.new(current_pack)
 var migration=Store.new("user://old_v43.json",current_raw.sha256_text(),current_pack.save_migrations)
 check(migration.load_game(migrated) and migrated.state.units[h].pending,"old V43 save loads without rewriting past arrival")
 migrated.end_side();migrated.end_side()
 check(not migrated.state.units[h].pending and migrated.distance(origin,migrated.unit_cell(migrated.state.units[h]))==1 and migrated.validate(migrated.state),"old V43 blocked HQ enters adjacent at next own turn")
 var f=FileAccess.open("user://adjacent_reinforcements.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"actual_raoult_entry":arrived,"original_entry":[15,4],"arrival_turn":3},"\t"));f.close()
 print("V43.1 ADJACENT REINFORCEMENTS ",checks-failures,"/",checks);quit(1 if failures else 0)
