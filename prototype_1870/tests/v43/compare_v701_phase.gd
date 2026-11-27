extends "res://tests/test_ai_compat0833.gd"
const V70=preload("res://tests/reference_v70/tactical_ai.gd")
func _initialize():
 var a=OS.get_cmdline_user_args();var policy=a[0];var checkpoint=a[1];var out=a[2]
 data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
 var e=Rules.new(data,JSON.parse_string(FileAccess.get_file_as_string(checkpoint)));e.normalize()
 check(e.validate(e.state) and e.state.side==0,"valid French checkpoint")
 var brain=V70.new() if policy=="v70" else bot();brain.profiles=profiles
 var turn=int(e.state.turn);var event_start=e.state.events.size();var orders=[];var start=Time.get_ticks_msec()
 for step in range(500):
  var view=e.observation(0);var before=view.duplicate(true);var action=brain.choose(view)
  check(view==before,"observation remains immutable")
  orders.append(action)
  check(dispatch(e,action) and e.validate(e.state),"legal real order "+JSON.stringify(action))
  if action.kind=="end" or failures>0:break
 check(e.state.side==1,"French phase really completed")
 var guns=[];var shots=0;var losses=0
 for n in range(e.state.units.size()):
  var u=e.state.units[n]
  if int(u.side)!=0 or not e.artillery(n):continue
  var fired=[]
  for k in range(event_start,e.state.events.size()):
   var event=e.state.events[k]
   if event.kind=="fire" and int(event.shooter)==n:fired.append(event)
  var hit=0
  for event in fired:hit+=int(event.loss)
  shots+=fired.size();losses+=hit
  guns.append({"unit":u.id,"shots":fired.size(),"direct_losses":hit,"alive":e.alive(n),"strength":u.strength,"ap":u.ap,"cell":u.cell.duplicate(),"deployed":u.deployed})
 var result={"policy":policy,"turn":turn,"checkpoint":checkpoint.get_file(),"protocol":"One native French phase, identical verified replay checkpoint; active historical Prussian actions before this checkpoint, no subsequent Prussian phase simulated here.","shots":shots,"direct_losses":losses,"guns":guns,"orders":orders,"checks":checks,"failures":failures,"elapsed_ms":Time.get_ticks_msec()-start}
 var f=FileAccess.open(out,FileAccess.WRITE);f.store_string(JSON.stringify(result,"\t"));f.close()
 print("PHASE COMPARISON ",checks-failures,"/",checks," ",JSON.stringify({"policy":policy,"turn":turn,"shots":shots,"losses":losses}));quit(1 if failures else 0)
