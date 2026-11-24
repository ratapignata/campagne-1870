extends "res://tests/test_ai_compat0833.gd"
const Prior=preload("res://tests/v43/reference_tactical_ai_v4315.gd")
func all_observed(e):
 var foes=[]
 for n in range(e.state.units.size()):
  if int(e.state.units[n].side)!=0:foes.append(n)
 return e.observation(0,foes)
func _initialize():
 var args=OS.get_cmdline_user_args();var mode=args[0];var seed_value=int(args[1]);var output=args[2]
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var p=data.duplicate(true);p.units=[];p.rules.fog.enabled=false;p.map.river_edges=[];p.map.tiles.fill("plain");p.map.elevations.fill(0)
 var ids=["fr_10","qg_fr_Pellé","pru_36","pru_37","pru_38","pru_39","pru_40","pru_41","qg_pr_Sandrart","qg_pr_Schmidt"]
 var cells=[[18,6],[15,2],[18,8],[20,5],[20,3],[17,8],[16,7],[17,3],[21,8],[20,10]]
 for id in ids:
  for u in data.units:
   if u.id==id:p.units.append(u.duplicate(true))
 for n in range(p.units.size()):p.units[n].cell=cells[n];p.units[n].arrival_turn=1
 var e=Rules.new(p);e.new_game(1,"hard");e.state.ai_style=0;e.state.seed=seed_value
 e.pack.map.tiles[e.index(Vector2i(18,6))]="forest";e.pack.map.tiles[e.index(Vector2i(16,4))]="forest"
 e.state.units[0].formation="line";e.state.units[0].entrenched=true
 var french=Prior.new() if mode=="reference" else bot();french.profiles=profiles
 var targets=[[18,7],[19,6],[19,5],[17,6],[17,5],[18,5]]
 var report={"mode":mode,"seed":seed_value,"protocol":"Focused synthetic closing trap, not a chronological battle. Ten original-strength units, all visible, plain map with two woods and no river. Same fixed legal Prussian ring-closing orders around the original Niederwald hex in both cases. Encircling troops hold the ring rather than pursue. French AI remains active. Measures warning/redeployment and real isolation surrender only; does not measure an adaptive human's win rate.","phases":[],"complete":false}
 check(e.validate(e.state),"prepared trap valid")
 while int(e.state.turn)<=6 and not e.state.finished and failures==0:
  var side=int(e.state.side);var turn=int(e.state.turn);var orders=[]
  if side==0:
   var ended=false
   for step in range(100):
    var a=french.choose(all_observed(e));check(dispatch(e,a),"legal French response "+JSON.stringify(a));check(e.validate(e.state),"valid trap state");orders.append(a)
    if a.kind=="end":ended=true;break
   check(ended,"French phase below action cap")
  else:
   for n in range(6):
    var unit=e.unit_index(ids[n+2]);var dest=e.index(Vector2i(targets[n][0],targets[n][1]))
    if not e.can_act(unit) or e.unit_cell(e.state.units[unit])==dest or e.unit_at(dest)>=0:continue
    var path=e.path_to(unit,dest)
    if path.is_empty():continue
    var action={"kind":"move","unit":ids[n+2],"path":path};check(dispatch(e,action),"ring closes by real legal movement");check(e.validate(e.state),"valid ring state");orders.append(action)
   e.end_side();check(e.validate(e.state),"ring phase completed")
  report.phases.append({"turn":turn,"side":side,"orders":orders,"french_strength":e.state.units[0].strength,"french_cell":e.state.units[0].cell.duplicate(),"french_prisoners":e.prisoners(0),"isolation_turns":e.state.units[0].isolation_turns,"command":e.state.units[0].command_ok,"supply":e.state.units[0].supply_ok})
 report.complete=failures==0 and int(e.state.turn)>6;report.checks=checks;report.failures=failures;report.french_prisoners=e.prisoners(0);report.french_remaining=e.state.units[0].strength
 var file=FileAccess.open(output,FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
 print("TRAP ",mode," ",seed_value," ",checks-failures,"/",checks," prisoners ",report.french_prisoners," remaining ",report.french_remaining);quit(1 if failures else 0)
