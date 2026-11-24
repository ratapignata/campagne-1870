extends "res://tests/test_ai_compat0833.gd"
func _initialize():
 var args=OS.get_cmdline_user_args();var path=args[0];var output=args[1]
 var original=FileAccess.get_file_as_bytes(path)
 var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json");data=JSON.parse_string(raw)
 var e=Rules.new(data);var store=Store.new(path,raw.sha256_text());var envelope=JSON.parse_string(original.get_string_from_utf8())
 check(envelope.export_info.version=="0.8.43.15","supplied export identifies exact V43.15")
 check(store.load_game(e) and e.validate(e.state),"real supplied final save loads through production loader")
 check(e.state.finished and e.state.turn==20 and e.state.human_side==1 and e.state.ai_difficulty=="hard","real player/difficulty and completed turn 20 preserved")
 var report={"result":e.result_for(1),"initial_force":[e.initial_force(0),e.initial_force(1)],"remaining":[e.initial_force(0)-e.military_losses(0),e.initial_force(1)-e.military_losses(1)],"losses":[e.losses(0),e.losses(1)],"prisoners":[e.prisoners(0),e.prisoners(1)],"captures":[],"surrenders":[],"phases":e.state.loss_history}
 for event in e.state.battle_history:
  if event.kind=="capture":report.captures.append(event)
  elif event.kind=="surrender":report.surrenders.append(event)
 check(report.losses==[16574,13900] and report.prisoners==[28976,120],"production totals agree with the recorded exported unit states")
 check(e.result_for(1).level=="major_win","actual final score is a Prussian major victory")
 var copy=Store.new("user://personal_reloaded.json",raw.sha256_text());var resumed=Rules.new(data)
 check(copy.save_game(e) and copy.load_game(resumed) and resumed.state==e.state and resumed.result_for(1)==e.result_for(1),"final state and score survive a new save/reload")
 check(FileAccess.get_file_as_bytes(path)==original,"original supplied save remains byte-identical")
 report.checks=checks;report.failures=failures
 var file=FileAccess.open(output,FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
 print("PERSONAL SAVE ",checks-failures,"/",checks," ",JSON.stringify(e.result_for(1)));quit(1 if failures else 0)
