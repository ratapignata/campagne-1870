extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
func _initialize():
 var data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v42_lot8.json"))
 var report={"seed":187037,"trials":[]}
 for id in ["pru_54","pru_55"]:
  var e=Rules.new(data);e.new_game(0,"medium");e.state.seed=187037;e.state.ai_style=0
  var n=e.unit_index(id);var h=e.unit_index("qg_fr_Raoult");var goal=e.unit_cell(e.state.units[h]);var trial={"id":id,"hq":data.units[h],"actions":[],"boundaries":[]}
  while int(e.state.turn)<=4:
   if int(e.state.side)==1 and e.can_act(n):
    for attempt in range(30):
     if not e.can_act(n) or e.unit_cell(e.state.units[n])==goal:break
     var long_path=e.path_to(n,goal,true)
     if long_path.is_empty():break
     var reach=e.reach(n);var dest=-1
     for cell in long_path:
      if reach.costs.has(cell) and e.unit_at(cell)<0:dest=cell
     if dest<0:break
     var path=e.path_to(n,dest)
     if path.size()<2:break
     var before=e.state.units[n].duplicate(true);var result=e.move(n,path)
     trial.actions.append({"turn":e.state.turn,"before":before,"path":path,"result":result,"after":e.state.units[n].duplicate(true),"valid":e.validate(e.state)})
   if int(e.state.turn)==3 and int(e.state.side)==0:
    var attempts=[]
    for attacker_id in ["fr_25","fr_31","fr_26","fr_32"]:
     var a=e.unit_index(attacker_id);var before=e.state.duplicate(true);var event=e.assault(a,n)
     attempts.append({"id":attacker_id,"unit":before.units[a],"status":e.assault_status(a,n),"event":event,"state_changed":before!=e.state,"defender":e.state.units[n].duplicate(true)})
    trial.attacks=attempts
   trial.boundaries.append({"turn":e.state.turn,"side":e.state.side,"cav_cell":e.state.units[n].cell,"hq_pending":e.state.units[h].pending,"hq_alive":e.alive(h),"occupant":e.unit_at(goal),"hq_visible_own":e.visible_to(0,h),"valid":e.validate(e.state)})
   e.end_side()
  report.trials.append(trial)
 var f=FileAccess.open("user://raoult_probe.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
 print("RAOULT PROBE ",JSON.stringify(report));quit()
