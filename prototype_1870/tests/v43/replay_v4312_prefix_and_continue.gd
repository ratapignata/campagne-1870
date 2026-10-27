extends "res://tests/test_ai_compat0833.gd"
func save_report(path,report,e):
 var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
 var s=FileAccess.open(path+".state.json",FileAccess.WRITE);s.store_string(JSON.stringify(e.state));s.close()
func occupant(e,w):
 var n=e.unit_at(w)
 return {"side":int(e.state.units[n].side),"id":str(e.state.units[n].id),"strength":int(e.state.units[n].strength)} if n>=0 else {"side":-1}

var french_bot
func defend_woerth(e,w):
 var holder=e.unit_at(w)
 if holder>=0 and int(e.state.units[holder].side)==0:
  if e.can_act(holder):
   if e.rally_status(holder)=="ok":return {"kind":"rally","unit":e.state.units[holder].id}
   for j in range(e.state.units.size()):
    if e.fire_status(holder,j)=="ok":return {"kind":"fire","unit":e.state.units[holder].id,"target":e.state.units[j].id}
   if e.entrench_status(holder)=="ok":return {"kind":"entrench","unit":e.state.units[holder].id}
   if e.rest_status(holder)=="ok" and int(e.state.units[holder].ammo_level)==2:return {"kind":"rest","unit":e.state.units[holder].id}
  var view=e.observation(0)
  for u in view.state.units:
   if str(u.id)==str(e.state.units[holder].id):u.done=true
  return french_bot.choose(view)
 if holder<0:
  var nearest=-1;var distance=10000
  for n in range(e.state.units.size()):
   if not e.can_act(n) or e.headquarters(n) or e.artillery(n) or e.cavalry(n) or e.state.units[n].morale=="routed":continue
   var d=e.distance(e.unit_cell(e.state.units[n]),w)
   if d<distance:distance=d;nearest=n
  if nearest>=0:
   var reach=e.reach(nearest);var best=-1;var gain=distance
   for cell in reach.costs:
    if e.unit_at(cell)>=0:continue
    var d=e.distance(cell,w)
    if d<gain:gain=d;best=cell
   if best>=0:
    var path=[best]
    while reach.parents.has(path[0]):path.push_front(reach.parents[path[0]])
    return {"kind":"move","unit":e.state.units[nearest].id,"path":path}
 return french_bot.choose(e.observation(0))

func _initialize():
 var args=OS.get_cmdline_user_args();var out=args[1];var original=JSON.parse_string(FileAccess.get_file_as_string(args[0]))
 profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json")))
 e.new_game(0,"hard");e.state.seed=18704311;e.state.ai_style=0
 var bots=[bot(),bot()];french_bot=bots[0];var w=e.index(Vector2i(13,10));var start=Time.get_ticks_msec()
 var report=original.duplicate(true);var replayed=[]
 check(e.validate(e.state),"initial state")
 for a in original.actions:
  if int(a.turn)>8 or (int(a.turn)==8 and int(a.side)==1):break
  check(int(e.state.turn)==int(a.turn) and int(e.state.side)==int(a.side),"chronological replay phase")
  check(dispatch(e,a.decision) and e.validate(e.state),"chronological replay legal")
  replayed.append(a)
  if replayed.size()%100==0:print("PREFIX REPLAY ",replayed.size())
 check(int(e.state.turn)==8 and int(e.state.side)==1,"replay reaches actual Prussian T8 without synthetic resets")
 report.actions=replayed;report.phases=original.phases.filter(func(row):return int(row.turn)<8 or (int(row.turn)==8 and int(row.side)==0));report.complete=false
 report.protocol="Full chronological V43.12 Hard battle: original autonomous prefix from T1 through French T8 replayed through actual engine, then final decision policy from Prussian T8 through T10. Priority adjustment activates only from T8; no positions, AP or combat states overwritten. Dedicated legal French defence of Woerth; not a human replay."
 report.replayed_prefix_actions=replayed.size();report.prefix_replay_checks=checks;report.prefix_replay_failures=failures
 while not e.state.finished and int(e.state.turn)<=10 and failures==0:
  var side=int(e.state.side);var turn=int(e.state.turn);var counts={};var elapsed=Time.get_ticks_msec();var moved={};var used=0;var phase_done=false
  for k in range(500):
   var then=Time.get_ticks_msec();var decision=defend_woerth(e,w) if side==0 else bots[1].choose(e.observation(side));var duration=Time.get_ticks_msec()-then
   var old=occupant(e,w);var n=e.unit_index(str(decision.get("unit","")));var ap=int(e.state.units[n].ap) if n>=0 else 0
   check(dispatch(e,decision),"legal action "+JSON.stringify(decision));check(e.validate(e.state),"valid state")
   counts[decision.kind]=int(counts.get(decision.kind,0))+1
   if n>=0 and decision.kind!="end":used+=maxi(0,ap-int(e.state.units[n].ap))
   if decision.kind=="move":moved[decision.unit]=true
   report.actions.append({"turn":turn,"side":side,"decision":decision,"decision_ms":duration})
   var now=occupant(e,w)
   if int(now.side)==1 and report.first_prussian_occupation==null:
    report.first_prussian_occupation={"turn":turn,"side_phase":side,"occupant":now,"action":decision};print("FIRST PRUSSIAN WOERTH ",JSON.stringify(report.first_prussian_occupation))
   if k%25==0:print("PROGRESS T",turn," side",side," decisions",k+1," counts ",JSON.stringify(counts))
   if failures or decision.kind=="end":phase_done=decision.kind=="end";break
  check(phase_done,"phase action cap not reached")
  report.phases.append({"turn":turn,"side":side,"counts":counts,"moved_units":moved.size(),"ap_used_quarters":used,"woerth":occupant(e,w),"goals":e.state.objective_owners.duplicate(),"losses":[e.losses(0),e.losses(1)],"prisoners":[e.prisoners(0),e.prisoners(1)],"routed":[e.routed_count(0),e.routed_count(1)],"elapsed_ms":Time.get_ticks_msec()-elapsed})
  report.checks=checks;report.failures=failures;report.elapsed_ms=Time.get_ticks_msec()-start
  save_report(out,report,e);print("DONE ",JSON.stringify(report.phases[-1]))
 report.complete=failures==0 and (int(e.state.turn)>10 or e.state.finished);report.checks=checks;report.failures=failures;report.elapsed_ms=Time.get_ticks_msec()-start
 save_report(out,report,e);print("FINISHED ",checks-failures,"/",checks," capture ",JSON.stringify(report.first_prussian_occupation));quit(1 if failures else 0)
