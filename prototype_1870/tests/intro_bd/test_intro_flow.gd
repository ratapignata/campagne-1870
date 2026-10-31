extends SceneTree
var game
var checks=0
var failures=0
var out=""
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func frame():
 await process_frame
 if DisplayServer.get_name()!="headless":await RenderingServer.frame_post_draw
func shot(name: String):
 if out.is_empty() or DisplayServer.get_name()=="headless":return
 await frame();check(root.get_texture().get_image().save_png(out+"/"+name+".png")==OK,"actual screenshot "+name)
func button(node: Node,text: String):
 if node is Button and node.text==text:return node
 for child in node.get_children():
  var found=button(child,text)
  if found!=null:return found
 return null
func tap(b: Button):
 check(b!=null and b.is_visible_in_tree() and not b.disabled,"touch target visible and enabled")
 if b==null or b.disabled:return
 if DisplayServer.get_name()=="headless":b.pressed.emit();await frame();return
 var event=InputEventScreenTouch.new();event.index=0;event.position=b.get_global_rect().get_center();event.pressed=true;Input.parse_input_event(event);await frame()
 event=InputEventScreenTouch.new();event.index=0;event.position=b.get_global_rect().get_center();event.pressed=false;Input.parse_input_event(event);await frame()
func viewer():return game.modal_box.get_node_or_null("Introduction1870") if is_instance_valid(game.modal_box) else null
func boot():
 game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop();await frame()
func start_intro():
 await tap(button(game.modal_box,game.t("start")))
 check(viewer()!=null,"fresh game starts with historical introduction")
func run():
 root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED;root.size=Vector2i(1280,720)
 var args=OS.get_cmdline_user_args();if args.size()>0:out=args[0]
 await boot();check(not game.has_save and viewer()==null,"fresh app opens menu, never a battle or forced introduction")
 await shot("menu")
 var state=JSON.stringify(game.engine.state);var undo=JSON.stringify(game.engine.previous);var path=game.saver.path
 check(not FileAccess.file_exists(path),"no slot created before actual scenario start")
 await start_intro();var v=viewer();var original=JSON.parse_string(FileAccess.get_file_as_string("res://tests/intro_bd/reviewed_content_02.json"))
 check(Array(v.TITLES)==original.titles and Array(v.DESCRIPTIONS)==original.descriptions,"six approved titles and revised historical descriptions displayed")
 check(v.ART.size()==6 and v.timer.wait_time==30.0,"six repaired images and thirty-second autoplay")
 for item_index in range(original.art.size()):
  var art=original.art[item_index]
  var f=FileAccess.open("res://intro_bd/assets/"+art.file,FileAccess.READ);var h=HashingContext.new();h.start(HashingContext.HASH_SHA256);h.update(f.get_buffer(f.get_length()));f.close()
  check(h.finish().hex_encode()==art.sha256 and v.ART[item_index]!=null and v.ART[item_index]==load("res://intro_bd/assets/"+art.file),"repaired illustration matches reviewed and loaded asset "+art.file)
 var preserved=JSON.parse_string(FileAccess.get_file_as_string("res://tests/intro_bd/original_content.json"))
 for art in preserved.art:
  var file=FileAccess.open("res://development/intro_bd_source/assets/"+art.file,FileAccess.READ);var hash=HashingContext.new();hash.start(HashingContext.HASH_SHA256);hash.update(file.get_buffer(file.get_length()));file.close()
  check(hash.finish().hex_encode()==art.sha256,"original JPEG archived intact "+art.file)
 for dimensions in [Vector2i(1280,606),Vector2i(1280,720),Vector2i(1520,720)]:
  root.size=dimensions;await frame();await frame()
  var screen=Rect2(Vector2.ZERO,Vector2(dimensions))
  for b in [v.menu_button,v.skip_button,v.previous_button,v.auto_button,v.next_button]:
   check(screen.encloses(b.get_global_rect()) and b.size.y>=48,"tactile controls fit landscape screen "+str(dimensions)+" actual "+str(b.get_global_rect())+" intro "+str(v.size))
   var style=b.get_theme_stylebox("normal");var width=b.get_theme_font("font").get_string_size(b.text,HORIZONTAL_ALIGNMENT_LEFT,-1,b.get_theme_font_size("font_size")).x
   check(width+style.get_minimum_size().x<=b.size.x,"complete button text fits")
  for k in range(6):
   v._show_scene(k);v.anim.custom_step(1.0);await frame()
   check(v.index==k and v.art.texture==v.ART[k] and v.description.text==v.DESCRIPTIONS[k],"correct panel and full text at "+str(dimensions))
   check(v.art.stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"complete illustration without new crop or distortion")
   check(screen.encloses(v.art_holder.get_global_rect()) and screen.encloses(v.text_holder.get_global_rect()),"content fits landscape screen")
   check(v.previous_button.disabled==(k==0) and not v.next_button.disabled,"previous/next state is reset on every panel")
   if dimensions==Vector2i(1280,720):await shot("scene_"+str(k+1))
  if dimensions.y==606:
   await shot("compact_606")
   v._show_scene(2);await frame();await frame();var bar=v.description_scroll.get_v_scroll_bar()
   if bar.max_value>bar.page:
    check(v.playback_note.text.contains("Glissez"),"overflowing history has a visible reading cue")
    if DisplayServer.get_name()!="headless":
     var point=v.description_scroll.get_global_rect().get_center();var press=InputEventScreenTouch.new();press.index=0;press.position=point;press.pressed=true;Input.parse_input_event(press);await frame()
     var drag=InputEventScreenDrag.new();drag.index=0;drag.position=point+Vector2(0,-100);drag.relative=Vector2(0,-100);Input.parse_input_event(drag);await frame()
     press=InputEventScreenTouch.new();press.index=0;press.position=drag.position;press.pressed=false;Input.parse_input_event(press);await frame()
     check(v.description_scroll.scroll_vertical>0,"French history scrolls with a real finger drag")
     await shot("compact_history_scrolled")
    v._show_scene(2);await frame();await frame();v._toggle_auto();await frame();await frame()
    check(v.scroll_anim!=null and v.scroll_anim.is_valid(),"automatic history creates scrolling only for overflowing text")
    if v.scroll_anim!=null and v.scroll_anim.is_valid():v.scroll_anim.custom_step(23.0)
    check(v.description_scroll.scroll_vertical>=int(bar.max_value-bar.page)-1,"automatic reading reaches the last history lines")
    if v.auto_play:v._toggle_auto()
 check(JSON.stringify(game.engine.state)==state and JSON.stringify(game.engine.previous)==undo and not FileAccess.file_exists(path),"navigation and resize cannot alter engine, undo or slot")
 root.size=Vector2i(1280,720);await frame();v._show_scene(0);v.anim.pause()
 await tap(v.next_button);check(v.index==1,"real next touch advances one panel")
 await tap(v.previous_button);check(v.index==0,"real previous touch returns one panel")
 await tap(v.auto_button);check(v.auto_play and not v.timer.is_stopped(),"autoplay touch starts timer")
 v._notification(v.NOTIFICATION_APPLICATION_FOCUS_IN);v._notification(v.NOTIFICATION_APPLICATION_PAUSED);var left=v.timer.time_left
 await create_timer(0.15).timeout;check(is_equal_approx(v.timer.time_left,left),"background pauses reading time")
 v._notification(v.NOTIFICATION_APPLICATION_RESUMED)
 # One real thirty-second interval, followed by a fast full-sequence timer exercise.
 await create_timer(30.1).timeout;check(v.index==1,"real integrated thirty-second timer advances")
 await tap(v.auto_button);check(not v.auto_play and v.timer.is_stopped(),"manual reading stops automatic timer")
 var illustration=weakref(v.ART[0]);v._show_scene(0);v.anim.pause();await tap(v.skip_button)
 await frame();await frame();check(illustration.get_ref()==null,"intro pictures released after leaving introduction")
 check(viewer()==null and button(game.modal_box,game.t("choose_france"))!=null,"skip during fade opens existing battle/configuration card immediately")
 check(button(game.modal_box,game.t("choose_france"))!=null and not FileAccess.file_exists(path),"skip never creates a battle/save automatically")
 await shot("battle_card")
 game.show_menu();await frame();await start_intro();v=viewer();await tap(v.menu_button)
 check(viewer()==null and button(game.modal_box,game.t("start"))!=null,"return menu does not start scenario")
 await start_intro();game._notification(game.NOTIFICATION_WM_GO_BACK_REQUEST);await frame()
 check(viewer()==null and button(game.modal_box,game.t("start"))!=null,"Android Back returns to menu, not underlying battle")
 await start_intro();v=viewer();v._show_scene(0);v._toggle_auto();v.timer.wait_time=0.04;v.timer.start()
 await create_timer(0.65).timeout
 check(viewer()==null and button(game.modal_box,game.t("choose_france"))!=null,"accelerated automatic reading completes all six panels once")
 check(JSON.stringify(game.engine.state)==state and not FileAccess.file_exists(path),"automatic completion remains read-only until side is chosen")
 await tap(button(game.modal_box,game.t("difficulty_hard")))
 check(viewer()==null and game.difficulty_choice=="hard","changing difficulty never replays intro")
 await tap(button(game.modal_box,game.t("choose_france")))
 check(game.playing and game.has_save and game.engine.state.ai_difficulty=="hard" and game.engine.state.human_side==0 and int(game.engine.state.turn)==1,"explicit side selection starts unchanged V43 scenario")
 check(game.engine.battle_turn_limit()==20 and game.engine.objective_value_total()==6,"20 turns and objective weights preserved")
 await shot("scenario_started")
 var snapshot=game.engine.state.duplicate(true);var slot=FileAccess.get_file_as_string(game.saver.path)
 game.show_menu();await frame();await tap(button(game.modal_box,game.t("continue")))
 check(viewer()==null and not is_instance_valid(game.modal) and game.engine.state==snapshot,"Continue enters saved battle directly")
 game.show_menu();await frame();await tap(button(game.modal_box,game.t("again")))
 check(viewer()==null,"replacement confirmation precedes any intro or new battle")
 await tap(button(game.modal_box,game.t("new_yes")));v=viewer();check(v!=null,"confirmed new game follows intro route")
 await tap(v.menu_button)
 check(FileAccess.get_file_as_string(game.saver.path)==slot and game.engine.state==snapshot,"abandoning intro keeps existing original save and state intact")
 game.playing=false;game.queue_free();await frame();await boot()
 check(game.has_save and game.engine.state==snapshot and viewer()==null,"fresh app instance loads existing save without intro")
 await tap(button(game.modal_box,game.t("continue")))
 check(viewer()==null and not is_instance_valid(game.modal) and game.playing,"loaded save enters directly on Continue")
 check(FileAccess.get_file_as_string(game.saver.path)==slot,"continuing does not rewrite or delete original slot")
 # Duplicate completion and late callbacks cannot start another flow.
 var lone=load("res://intro_bd/intro.tscn").instantiate();root.add_child(lone);var ends=[0];lone.introduction_finished.connect(func():ends[0]+=1)
 lone._finish();lone._finish();lone._next();check(ends[0]==1 and lone.timer.is_stopped(),"finish is idempotent and stops late timers")
 lone.queue_free();game.playing=false;game.queue_free();await frame();print("INTRO FLOW ",checks-failures,"/",checks);quit(1 if failures else 0)
