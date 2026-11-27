extends "res://tests/test_ai_compat0833.gd"
func guns(e):
 var result=[]
 for n in range(e.state.units.size()):
  var u=e.state.units[n]
  if int(u.side)!=0 or not e.artillery(n):continue
  var r={"unit":u.id,"cell":u.cell.duplicate(),"ap":u.ap,"limit":u.get("turn_ap_limit",16),"deployed":u.deployed,"alive":e.alive(n),"pending":u.pending,"command":u.command_ok,"supply":u.supply_ok,"ready":[],"forecast":[],"reasons":{}}
  for j in range(e.state.units.size()):
   if int(e.state.units[j].side)==0 or not e.alive(j) or not e.visible_to(0,j):continue
   var status=e.fire_status(n,j)
   r.reasons[status]=int(r.reasons.get(status,0))+1
   if status=="ok":r.ready.append(e.state.units[j].id)
  var ap=u.ap;var deployed=u.deployed;var done=u.done
  u.ap=e.max_ap(n);u.deployed=true;u.done=false
  for j in range(e.state.units.size()):
   if int(e.state.units[j].side)==1 and e.fire_status(n,j)=="ok":r.forecast.append(e.state.units[j].id)
  u.ap=ap;u.deployed=deployed;u.done=done
  result.append(r)
 return result
func _initialize():
 var a=OS.get_cmdline_user_args();var source=JSON.parse_string(FileAccess.get_file_as_string(a[0]));var final=JSON.parse_string(FileAccess.get_file_as_string(a[0]+".state.json"));var out=a[1]
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"))
 var e=Rules.new(data);e.new_game(1,"hard");e.state.seed=int(source.seed);e.state.ai_style=int(source.style)
 var log=[];var phases={}
 for row in source.actions:
  check(int(row.side)==int(e.state.side) and int(row.turn)==int(e.state.turn),"replay turn/side")
  if int(row.side)==0:
   var key=str(row.turn)
   if not phases.has(key):
    phases[key]=true
    var f=FileAccess.open(out+"/checkpoint_T"+key+".json",FileAccess.WRITE);f.store_string(JSON.stringify(e.state));f.close()
    log.append({"turn":row.turn,"kind":"phase_start","guns":guns(e)})
   var n=e.unit_index(str(row.action.get("unit","")))
   if n>=0 and e.artillery(n):log.append({"turn":row.turn,"kind":row.action.kind,"unit":row.action.unit,"guns":guns(e)})
  check(dispatch(e,row.action),"replay native order")
 check(e.state.events.size()==final.events.size(),"same event count")
 for k in range(e.state.events.size()):
  check(e.state.events[k].loss==int(final.events[k].loss) and e.state.events[k].return_loss==int(final.events[k].return_loss),"same deterministic combat exchange")
 for n in range(e.state.units.size()):
  var u=e.state.units[n];var v=final.units[n]
  check(u.strength==int(v.strength) and u.casualties==int(v.casualties) and u.prisoners==int(v.prisoners) and e.unit_cell(u)==e.index(Vector2i(int(v.cell[0]),int(v.cell[1]))),"same unit final strength/losses/position")
 var f=FileAccess.open(out+"/replay.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"log":log},"\t"));f.close()
 print("REPLAY ",checks-failures,"/",checks);quit(1 if failures else 0)
