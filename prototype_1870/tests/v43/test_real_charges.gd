extends "res://tests/v43/test_raoult.gd"
func _initialize():call_deferred("run_real")
func run_real():
 var e=blocked();var target=e.unit_index("pru_55");var h=e.unit_index("qg_fr_Raoult");var target_hex=e.unit_cell(e.state.units[target]);var combats=[]
 for id in ["fr_25","fr_31","fr_26","fr_32"]:
  var n=e.unit_index(id)
  for attempt in range(10):
   if e.distance(e.unit_cell(e.state.units[n]),target_hex)==1:break
   var reached=e.reach(n);var best=-1;var cost=100000
   for pos in e.neighbours(target_hex):
    if e.unit_at(pos)>=0 or not reached.costs.has(pos):continue
    var value=int(reached.costs[pos])
    if value<cost and value+e.assault_cost(n)<=int(e.state.units[n].ap):best=pos;cost=value
   if best<0:break
   var path=e.path_to(n,best);var move=e.move(n,path)
   check(move in ["moved","discovered","capture"] and e.validate(e.state),"French cavalry approach is a real legal movement")
  var before=e.state.units[target].duplicate(true);var attacker=e.state.units[n].duplicate(true);var status=e.assault_status(n,target)
  check(status=="ok","actual French cavalry charge available "+id)
  if status!="ok":continue
  var r=e.assault(n,target);check(r.status=="ok" and e.validate(e.state),"actual charge preserves valid 95-unit state")
  check(int(before.strength)-int(e.state.units[target].strength)==int(r.event.loss)+int(r.event.prisoners),"actual defender losses persist")
  combats.append({"unit":id,"attacker_before":attacker,"defender_before":before,"defender_after":e.state.units[target].duplicate(true),"event":r.event})
  if combats.size()==2:
   var store=Store.new("user://after_two_charges.json","v43-real-cavalry");var copy=Rules.new(e.pack)
   check(store.save_game(e) and store.load_game(copy),"real physical save and reload between successive assaults")
   check(JSON.parse_string(JSON.stringify(copy.state))==JSON.parse_string(JSON.stringify(e.state)),"all state and actual losses preserved between assaults")
   e=copy
 check(combats.size()==4,"four actual French charges reproduced without relocating units")
 check(e.state.units[h].pending and e.unit_at(target_hex)==target,"village defender legally still blocks scheduled HQ")
 var f=FileAccess.open("user://real_successive_charges.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"seed":187037,"fixture":"Exact 95-unit Lot 8, no altered positions or strengths; scripted legal approaches and attacks, physical save after charge two.","cavalry_approach_actions":actions,"combats":combats},"\t"));f.close()
 print("V43 REAL SUCCESSIVE CHARGES ",checks-failures,"/",checks);quit(1 if failures else 0)
