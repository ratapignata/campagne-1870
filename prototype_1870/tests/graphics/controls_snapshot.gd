extends SceneTree
var game
var snapshots=[]
func _initialize():call_deferred("run")
func control(b):
 var methods=[]
 for c in b.get_signal_connection_list("pressed"):methods.append(c.callable.get_method())
 var rect=b.get_global_rect()
 return {"text":b.text,"visible":b.visible,"disabled":b.disabled,"rect":[rect.position.x,rect.position.y,rect.size.x,rect.size.y],"callbacks":methods,"mouse_filter":b.mouse_filter}
func run():
 root.size=Vector2i(1280,720);game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop();game.new_game(0);game.ai_enabled=false;game.music_player.stop()
 for kind in ["infantry","cavalry","artillery","hq","isolation","route"]:
  var data=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));var state=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/v4313_t11_simulation.json"));var e=game.EngineRules.new(data,state);e.normalize();e.refresh_intel();game.engine=e;game.map.engine=e;game.selected=-1;game.clear_preview();game.support_notice_seen=int(e.state.get("support_serial",0))
  for n in range(e.state.units.size()):
   if not e.alive(n) or int(e.state.units[n].side)!=0:continue
   if kind=="cavalry" and e.cavalry(n) or kind=="artillery" and e.artillery(n) or kind=="hq" and e.headquarters(n) or kind in ["infantry","isolation","route"] and not e.cavalry(n) and not e.artillery(n) and not e.headquarters(n):game.selected=n;break
  if kind=="isolation":
   var u=e.state.units[game.selected];u.command_ok=false;u.supply_ok=false;u.turn_ap_limit=8;u.ap=8;u.isolation_turns=1
  if kind=="route":
   for dest in e.reach(game.selected).costs:
    if e.unit_at(dest)<0:
     game.route=e.path_to(game.selected,dest);game.full_route=game.route.duplicate();break
  game.refresh();await process_frame
  var buttons={}
  for key in game.actions:buttons[key]=control(game.actions[key])
  buttons.formation=control(game.formation_button)
  for n in range(game.header_buttons.size()):buttons["header_"+str(n)]=control(game.header_buttons[n])
  snapshots.append({"case":kind,"buttons":buttons,"unit_text":[game.unit_label.text,game.unit_info.text,game.unit_state.text,game.unit_ap.text,game.support_label.text,game.supply_label.text,game.formation_label.text],"header_rect":[game.header.size.x,game.header.size.y],"footer_rect":[game.footer.position.x,game.footer.position.y,game.footer.size.x,game.footer.size.y]})
 var f=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);f.store_string(JSON.stringify(snapshots,"\t"));f.close()
 game.playing=false;game.queue_free();await process_frame;print("CONTROL SNAPSHOTS ",snapshots.size());quit()
