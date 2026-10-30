extends "res://tests/test_ai_compat0833.gd"
const Prior=preload("res://tests/v43/reference_ai_v4314.gd")
func scenario():
 var p=data.duplicate(true);p.units=[];p.objectives=[data.objectives[1].duplicate(true)];p.erase("previous_objectives")
 var ids=["fr_6","fr_7","fr_8","fr_9","fr_10","qg_fr_Pellé","art_fr_Pellé0","pru_36","pru_37","pru_38","pru_39","pru_40","pru_41","pru_42","pru_43","qg_pr_Sandrart","qg_pr_Schmidt","art_pr_Sandrart0","art_pr_Schmidt0"]
 var cells=[[13,10],[12,9],[14,9],[12,8],[14,8],[13,7],[11,8],[12,13],[13,13],[14,13],[12,14],[13,14],[14,14],[11,14],[15,14],[12,16],[14,16],[11,15],[15,15]]
 for id in ids:
  for u in data.units:
   if u.id==id:p.units.append(u.duplicate(true))
 for n in range(p.units.size()):p.units[n].cell=cells[n];p.units[n].arrival_turn=1
 return p
func _initialize():
 var args=OS.get_cmdline_user_args();var mode=args[0];var out=args[1];var seed_value=int(args[2])
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=Rules.new(scenario());e.new_game(1,"hard");e.state.turn=6;e.state.seed=seed_value;e.state.ai_style=0;e.refresh_support(false);e.refresh_intel()
 var french=bot() if mode=="current" else Prior.new();french.profiles=profiles;var prussian=Prior.new();prussian.profiles=profiles
 var report={"mode":mode,"seed":seed_value,"protocol":"Synthetic T6 crossing engagement on unchanged Sauer terrain/LOS, one Woerth objective. Five French infantry plus battery/HQ against eight Prussian infantry, two batteries/two HQ. Original individual strengths/AP/weapons. All present at start; not a chronological main battle.","phases":[],"complete":false,"first_capture":null};check(e.validate(e.state),"synthetic crossing valid")
 while int(e.state.turn)<=9 and not e.state.finished and failures==0:
  var side=int(e.state.side);var turn=int(e.state.turn);var counts={};var ended=false
  for k in range(200):
   var view=e.observation(side)
   if side==0 and mode=="normal":view.state.ai_difficulty="medium"
   var chosen=french.choose(view) if side==0 else prussian.choose(view)
   check(dispatch(e,chosen),"legal crossing action "+JSON.stringify(chosen));check(e.validate(e.state),"valid crossing state")
   counts[chosen.kind]=int(counts.get(chosen.kind,0))+1
   if e.state.objective_owners.elsasshausen==1 and report.first_capture==null:report.first_capture=turn
   if failures or chosen.kind=="end":ended=chosen.kind=="end";break
  check(ended,"crossing phase below cap")
  report.phases.append({"turn":turn,"side":side,"counts":counts,"owner":e.state.objective_owners.elsasshausen,"losses":[e.losses(0),e.losses(1)],"prisoners":[e.prisoners(0),e.prisoners(1)]});print("CROSSING ",mode," seed",seed_value," ",JSON.stringify(report.phases[-1]))
 report.complete=failures==0 and (int(e.state.turn)>9 or e.state.finished);report.checks=checks;report.failures=failures;report.initial_force=[e.initial_force(0),e.initial_force(1)]
 var f=FileAccess.open(out,FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close();print("CROSSING ",checks-failures,"/",checks);quit(1 if failures else 0)
