extends SceneTree
const Rules=preload("res://war_engine/core/engine.gd")
const Available=preload("res://war_engine/presentation/unit_availability.gd")
func _initialize():
 var e=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json")),JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/v4313_t11_simulation.json")));e.normalize();e.refresh_intel()
 var a=Available.new();var times=[];var before=JSON.stringify(e.state)
 for k in range(35):
  var start=Time.get_ticks_usec();a.update(e)
  if k>=5:times.append(float(Time.get_ticks_usec()-start)/1000.0)
 times.sort();var total=0.0
 for value in times:total+=value
 var report={"iterations":times.size(),"median_ms":times[times.size()/2],"p95_ms":times[int(times.size()*.95)],"average_ms":total/times.size(),"state_unchanged":before==JSON.stringify(e.state),"scope":"Desktop CPU, T11 fixture, UI classification only; not an Android benchmark"}
 var f=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close();print(report);quit()
