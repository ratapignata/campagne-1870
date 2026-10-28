extends SceneTree
const Report=preload("res://war_engine/presentation/battle_report.gd")
var checks=0
var failures=0
func check(ok,msg):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",msg)
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720);var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop();game.new_game(0);game.ai_enabled=false;game.music_player.stop()
 var e=game.engine;var n=e.unit_index("fr_1");var u=e.state.units[n];game.selected=n;game.clear_preview()
 u.command_ok=false;u.supply_ok=false;u.command_reason="enemy";u.supply_reason="detour";u.command_distance=11;u.hq_id="qg_fr_Ducrot";u.turn_ap_limit=16;u.isolation_turns=1
 game.refresh();await process_frame
 check(game.encircled_label.text==game.t("link_double_short"),"double cut explicitly named on unit card")
 var text=game.link_info_text(n,true)
 check(text.contains("Double coupure") and text.contains("QG : Ducrot"),"link detail includes combined status and own HQ")
 check(text.contains("2 / 4 PA") and text.contains("actuel : 4 PA"),"current and next renewal AP distinguished")
 check(text.contains("chemin sûr") and text.contains("encerclement"),"safe corridor versus physical encirclement explained")
 check(game.link_info_text(e.unit_index("pru_36"),true).is_empty(),"opposing liaison detail inaccessible")
 for which in [true,false]:
  game.show_link_info(which);await process_frame;var labels=game.modal_box.find_children("*","RichTextLabel",true,false)
  check(labels.size()==1 and labels[0].text.contains("Double coupure"),"command and supply detail dialogs render")
  game.close_modal()
 var event={"side":0,"links":{"command_ok":false,"supply_ok":true,"command_reason":"distance","supply_reason":"ok"}}
 check(game.link_journal_detail(event).contains("Hors commandement"),"journal names the recorded lost liaison")
 check(game.link_journal_detail({"side":0}).contains("ancienne sauvegarde"),"legacy journal does not invent causes")
 event.side=1;check(game.link_journal_detail(event).is_empty(),"opponent diagnostic never disclosed")
 game.show_journal();await process_frame;var content=game.modal_box.find_children("*","RichTextLabel",true,false)[0].text
 check(content.contains("Wœrth : 2 points") and not content.contains("Elsasshausen : 2"),"journal lists actual current goals")
 game.close_modal();e.state.finished=true;var before=JSON.stringify(e.state);game.show_battle_details();await process_frame
 content=game.modal_box.find_children("*","RichTextLabel",true,false)[0].text
 check(content.contains("BILAN DES FORCES") and content.contains("CALCUL DU SCORE") and content.contains("ÉVOLUTION DES PERTES"),"detailed battle report opens through real UI")
 check(content.contains("Wœrth · 2 points") and content.contains("prisonniers"),"goal and prisoners rendered")
 check(JSON.stringify(e.state)==before,"opening report leaves save state untouched")
 # Optional screenshot path for an actual rendered final report.
 var args=OS.get_cmdline_user_args()
 if args.size()>0:
  await process_frame;await process_frame
  var image=root.get_texture().get_image();check(image.save_png(args[0])==OK,"report screenshot written")
 game.playing=false;game.queue_free();await process_frame
 print("V43.14 UI ",checks-failures,"/",checks);quit(1 if failures else 0)
