extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var game=load("res://main.tscn").instantiate();root.add_child(game);game.ai_enabled=false;game.sound_enabled=false;game.music_player.stop()
 for i in range(36,54):
  var name=game.t("reg_pru_"+str(i))
  check("RI" in name or "bataillon" in name,"unit echelon explicit "+str(i))
 for side in [0,1]:
  game.new_game(side);game.ai_enabled=false;game.music_player.stop()
  for dimensions in [Vector2i(1280,606),Vector2i(1520,720)]:
   root.size=dimensions;await process_frame;await process_frame
   var ids=["fr_1","art_fr_Raoult0","fr_25"] if side==0 else ["pru_48","pru_52","art_pr_Gersdorff0","pru_55"]
   for id in ids:
    var n=game.engine.unit_index(id)
    if n<0:continue
    var u=game.engine.state.units[n]
    if u.pending:u.pending=false;u.strength=u.initial_strength;u.ap=16;u.done=false
    game.selected=n;game.target=-1;game.map.focus=game.map.world(game.engine.unit_cell(u));game.map.zoom=1.15;game.refresh();await process_frame
    check(game.weapon_label.text.is_empty(),"weapon line empty "+id)
    check("QG" not in game.unit_label.text,"no HQ suffix on regiment "+id)
    check(is_equal_approx(game.ammo_label.position.y,100.0),"gap removed "+id)
    check(game.ammo_label.position.y>=game.unit_state.position.y+game.unit_state.size.y,"state and ammunition do not overlap")
    check(game.unit_reaction.position.y>=game.ammo_label.position.y+game.ammo_label.size.y,"ammunition and reaction do not overlap")
    var font=game.unit_label.get_theme_font("font");var fs=game.unit_label.get_theme_font_size("font_size")
    check(font.get_string_size(game.unit_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x<=game.unit_label.size.x+1,"complete title fits "+id)
    if DisplayServer.get_name()!="headless" and dimensions.x==1280:
     await RenderingServer.frame_post_draw
     root.get_texture().get_image().save_png("user://"+id+".png")
 game.playing=false;game.queue_free();await process_frame
 print("V43.9 PRESENTATION ",checks-failures,"/",checks);quit(1 if failures else 0)
