extends SceneTree
var game
var report={"captures":[],"benchmark":{}}
var out: String
func digest_bytes(bytes: PackedByteArray) -> String:
 var ctx=HashingContext.new();ctx.start(HashingContext.HASH_SHA256);ctx.update(bytes);return ctx.finish().hex_encode()
func _initialize():call_deferred("run")
func set_case(kind: String):
 var pack=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json"));var state=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/v4313_t11_simulation.json"))
 var e=game.EngineRules.new(pack,state)
 if kind=="deplacement":e.new_game(0,"hard");e.state.seed=1870431503;e.state.ai_style=0
 e.normalize();e.refresh_intel();game.engine=e;game.map.engine=e;game.selected=-1;game.clear_preview();game.support_notice_seen=int(e.state.get("support_serial",0));game.pending_hq_notice="";game.playing=true;game.ai_enabled=false
 var focus=e.index(Vector2i(14,9));var zoom=0.82
 if kind=="deplacement":focus=e.index(Vector2i(11,5));zoom=1.15;game.selected=e.unit_index("fr_9")
 elif kind=="engagement":focus=e.index(Vector2i(15,7));zoom=1.05;game.selected=e.unit_index("fr_14")
 elif kind=="prussiens":
  e.state.human_side=1;e.end_side();e.refresh_intel();focus=e.index(Vector2i(16,9));zoom=1.05;game.selected=e.unit_index("pru_44");game.support_notice_seen=int(e.state.get("support_serial",0))
 elif kind=="isolement":
  var n=e.unit_index("fr_14");var u=e.state.units[n];u.command_ok=false;u.supply_ok=false;u.isolation_turns=1;u.turn_ap_limit=8;u.ap=8;u.command_reason="enemy";u.supply_reason="enemy"
  game.selected=e.unit_index("qg_fr_Raoult");zoom=1.0
  game.map.focus=(game.map.world(e.unit_cell(u))+game.map.world(e.unit_cell(e.state.units[game.selected])))/2
  focus=-1
 elif kind=="detail":focus=e.index(Vector2i(17,7));zoom=1.55;game.selected=e.unit_index("fr_14")
 game.map.zoom=zoom
 if focus>=0:game.map.focus=game.map.world(focus)
 game.refresh();game.map.queue_redraw()
func capture(name):
 for warm in range(12):
  game.map.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
 var state_before=JSON.stringify(game.engine.state)
 var image=root.get_texture().get_image();var region=game.unit_card.get_global_rect();var crop=image.get_region(Rect2i(region))
 var strips={};var artwork={}
 for n in range(game.engine.state.units.size()):
  var u=game.engine.state.units[n]
  if not game.engine.alive(n) or int(u.side)!=int(game.engine.state.human_side):continue
  var center=game.map.global_position+game.map.screen(game.engine.unit_cell(u));var z=game.map.zoom
  var rect=Rect2i(Rect2(center+Vector2(-20,16)*z,Vector2(43,9)*z))
  if Rect2i(game.map.get_global_rect()).encloses(rect):strips[str(u.id)]=digest_bytes(image.get_region(rect).get_data())
  var art=Rect2i(Rect2(center+Vector2(-24,-25)*z,Vector2(48,37)*z))
  if Rect2i(game.map.get_global_rect()).encloses(art):artwork[str(u.id)]={"side":int(u.side),"rect":[art.position.x,art.position.y,art.size.x,art.size.y]}
 var error=image.save_png(out+"/"+name+".png")
 report.captures.append({"case":name,"force_strips":strips,"artwork":artwork,"png_error":error,"size":[image.get_width(),image.get_height()],"state_hash":state_before.sha256_text(),"left_card_hash":digest_bytes(crop.get_data()),"left_card_rect":[region.position.x,region.position.y,region.size.x,region.size.y],"focus":[game.map.focus.x,game.map.focus.y],"zoom":game.map.zoom,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"video_memory":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)})
 print("CAPTURE ",name," ",error)
func benchmark():
 var samples=[]
 for n in range(75):
  var then=Time.get_ticks_usec();game.map.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
  if n>=15:samples.append(float(Time.get_ticks_usec()-then)/1000.0)
 samples.sort();var total=0.0
 for v in samples:total+=v
 report.benchmark={"frames":samples.size(),"median_ms":samples[samples.size()/2],"p95_ms":samples[int(samples.size()*0.95)],"average_ms":total/samples.size(),"renderer":RenderingServer.get_video_adapter_name(),"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"video_memory":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)}
func run():
 out=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(out);root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1280,720)
 game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop();game.new_game(0);game.ai_enabled=false;game.music_player.stop()
 set_case("engagement");await capture("_warmup");report.captures.clear();DirAccess.remove_absolute(out+"/_warmup.png")
 for kind in ["overview","engagement","prussiens","isolement","detail","deplacement"]:
  set_case(kind);await capture(kind)
 set_case("engagement");await benchmark()
 var f=FileAccess.open(out+"/metrics.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
 game.playing=false;game.queue_free();await process_frame;print("CAPTURES COMPLETE ",JSON.stringify(report.benchmark));quit()
