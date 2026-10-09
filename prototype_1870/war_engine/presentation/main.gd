extends Control
const EngineRules=preload("res://war_engine/core/engine.gd")
const SaveStore=preload("res://war_engine/platform/save_store.gd")
const MapView=preload("res://war_engine/presentation/map_view.gd")
const BODY=preload("res://assets/fonts/DejaVuSans.ttf")
const TITLE=preload("res://assets/fonts/DejaVuSerif-Bold.ttf")
const FLAGS=[preload("res://assets/flag_fr.svg"),preload("res://assets/flag_de.svg")]
const LOGO=preload("res://assets/logo.svg")
const TacticalAI=preload("res://war_engine/ai/tactical_ai.gd")
const INK=Color("192f31")
const GOLD=Color("d4b06c")
const PAPER=Color("eee6cf")
var engine
var ai=TacticalAI.new()
var difficulty_choice="medium"
var ai_thread: Thread
var ai_generation=0
var ai_pending: Dictionary={}
var ai_clock=0.0
var ai_enabled=true
var app_suspended=false
var sound_enabled=true
var music_enabled=true
const SCENARIOS={"historical":{"pack":"regimental_trial.json","save":"save_regimental0835.json"},"classic":{"pack":"prototype.json","save":"save_classic_v0835.json"},"three":{"pack":"three_objectives.json","save":"save_three_v0835.json"}}
var scenario_choice="three"
func active_scenario() -> String:return "historical" if engine!=null and engine.pack.get("id","") in ["historical_terrain_trial0825","regimental_trial0828","regimental_trial0829","regimental_trial0830","regimental_trial0831","regimental_trial0832","regimental_trial0833","regimental_trial0834","regimental_trial0835"] else "three" if engine!=null and engine.pack.get("id","")=="trial_three_objectives_v0819" else "classic"
var prefs_path="user://preferences.cfg"
var music_player: AudioStreamPlayer
var assault_player: AudioStreamPlayer
var weapon_label: Label
var formation_button: Button
var formation_label: Label
var unit_state: Label
var unit_reaction: Label
var sound_player: AudioStreamPlayer
var sound_streams={}
var saver
var texts: Dictionary
var map
var inspected=-1
var inspected_report=-1
var terrain_label: Label
var reaction_player: AudioStreamPlayer
var selected=-1
var target=-1
var route: Array=[]
var full_route: Array=[]
var playing=false
var has_save=false
var legacy_game=false
var modal: Control
var modal_box: Control
var header: Control
var footer: Control
var hint_bar: Control
var mission: Control
var actions: Dictionary={}
var turn_label: Label
var score_label: Label
var unit_flag: TextureRect
var unit_label: Label
var unit_info: Label
var unit_ap: Label
var context_label: Label
var unit_card: Control
var action_card: Control
var ammo_label: Label
var support_label: Label
var supply_label: Label
var encircled_label: Label
var context_detail: Label
var hint: Label
var status: Label
var objective_owner: Label
var header_buttons: Array=[]
var hq_seen: Dictionary={}
var pending_hq_notice=""
func unit_heading(n: int) -> String:
	var u=engine.state.units[n];var title=t(str(u.name_key)+"_short")
	if int(u.side)==int(engine.state.human_side) and not engine.artillery(n) and not engine.headquarters(n):
		var leader=engine.unit_index(str(u.get("hq_id","")))
		if leader>=0:title=title.replace(" · Prusse","")+" · "+t(str(engine.state.units[leader].name_key)+"_short")
	var fs=21
	while fs>14 and BODY.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x>unit_label.size.x:fs-=1
	unit_label.add_theme_font_size_override("font_size",fs)
	unit_label.tooltip_text=title
	return title
func t(key: String) -> String:
	if engine!=null and engine.river_links.is_empty():
		var legacy={"objective":"Hauteur centrale","objective_hint":"Prenez et conservez la hauteur centrale."}
		if legacy.has(key):return legacy[key]
	return str(texts.get(key,key))
func _ready():
	ai.profiles=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/ai_profiles.json"))
	var start_prefs=ConfigFile.new()
	if start_prefs.load(prefs_path)==OK:scenario_choice=str(start_prefs.get_value("game","scenario","three"))
	if not SCENARIOS.has(scenario_choice):scenario_choice="three"
	var raw=FileAccess.get_file_as_string("res://packs/1870/"+str(SCENARIOS[scenario_choice].pack))
	engine=EngineRules.new(JSON.parse_string(raw));texts=JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/fr.json"))
	saver=SaveStore.new("user://"+str(SCENARIOS[scenario_choice].save),raw.sha256_text());has_save=saver.load_game(engine)
	if not has_save:
		for entry in [["legacy0834_regimental_trial.json","save_regimental0834.json"],["legacy0834_prototype.json","save_classic_v0834.json"],["legacy0834_three_objectives.json","save_three_v0834.json"],["legacy0833_regimental_trial.json","save_regimental0833.json"],["legacy0833_prototype.json","save_classic_v0833.json"],["legacy0833_three_objectives.json","save_three_v0833.json"],["legacy0832_regimental_trial.json","save_regimental0832.json"],["legacy0832_prototype.json","save_classic_v0832.json"],["legacy0832_three_objectives.json","save_three_v0832.json"],["legacy0831_regimental_trial.json","save_regimental0831.json"],["legacy0831_prototype.json","save_classic_v0831.json"],["legacy0831_three_objectives.json","save_three_v0831.json"],["legacy0830_regimental_trial.json","save_regimental0830.json"],["legacy0830_prototype.json","save_classic_v0830.json"],["legacy0830_three_objectives.json","save_three_v0830.json"],["legacy0829_regimental_trial.json","save_regimental0829.json"],["legacy0829_prototype.json","save_classic_v0829.json"],["legacy0829_three_objectives.json","save_three_v0829.json"],["legacy0828_regimental_trial.json","save_regimental0828.json"],["legacy0828_prototype.json","save_classic_v0822.json"],["legacy0828_three_objectives.json","save_three_v0822.json"],["regimental_trial.json","save_regimental0835.json"],["historical_trial.json","save_historical_trial0825.json"],["prototype.json","save_classic_v0835.json"],["three_objectives.json","save_three_v0835.json"],["legacy0821.json","save_classic_v0821.json"],["legacy_three0821.json","save_three_v0821.json"],["legacy0820.json","save_classic_v0820.json"],["legacy_three0820.json","save_three_v0820.json"],["legacy0819.json","save_v0816.json"],["legacy_three0819.json","save_three_v0819.json"],["legacy0818.json","save_v0816.json"],["legacy0815.json","save_v0815.json"],["legacy0814.json","save_v0814.json"],["legacy0813.json","save_v0813.json"],["legacy0811.json","save_v0811.json"],["legacy0810.json","save_v0810.json"],["legacy089.json","save_v089.json"],["legacy088.json","save_v086.json"],["legacy085.json","save_v085.json"],["legacy084.json","save_v081.json"]]:
			var legacy_raw=FileAccess.get_file_as_string("res://packs/1870/"+entry[0])
			var legacy_engine=EngineRules.new(JSON.parse_string(legacy_raw))
			var legacy_saver=SaveStore.new("user://"+entry[1],legacy_raw.sha256_text())
			if legacy_saver.load_game(legacy_engine) or (entry[0]=="legacy084.json" and legacy_saver.import_compatible(legacy_engine,legacy_engine.pack.get("save_compatibility",[]))):
				engine=legacy_engine;saver=legacy_saver;has_save=true;legacy_game=true
				if engine.pack.get("unit_types",{}).has("cavalry"):engine.pack.unit_types.cavalry.charge_ap=8
				break
	if has_save:scenario_choice=active_scenario()
	if has_save and engine.state.ai_difficulty in ["easy","medium","hard"]:difficulty_choice=engine.state.ai_difficulty
	var prefs=ConfigFile.new()
	if prefs.load(prefs_path)==OK:
		sound_enabled=bool(prefs.get_value("audio","enabled",true));music_enabled=bool(prefs.get_value("audio","music",true))
	sound_player=AudioStreamPlayer.new();add_child(sound_player);sound_player.volume_db=-5
	reaction_player=AudioStreamPlayer.new();add_child(reaction_player);reaction_player.volume_db=-6
	assault_player=AudioStreamPlayer.new();add_child(assault_player);assault_player.volume_db=-10
	music_player=AudioStreamPlayer.new();add_child(music_player);music_player.stream=load(engine.pack.music.path);music_player.stream.loop=true;music_player.volume_db=float(engine.pack.music.volume_db)
	if music_enabled:music_player.play()
	for key in engine.pack.sounds:sound_streams[key]=load(engine.pack.sounds[key])
	build_ui()
	reset_map_view()
	refresh();show_menu()
func reset_map_view():
	var view=engine.pack.map.get("view",{})
	var c=view.get("focus_cell",[22,11])
	map.focus=map.world(engine.index(Vector2i(int(c[0]),int(c[1])))) if engine.pack.map.get("north_left",false) else Vector2(765,580)
	map.zoom=float(view.get("zoom",1.05 if engine.pack.map.get("north_left",false) else 1.18))
func place(node: Control,parent: Node,x: float,y: float,w: float,h: float):
	parent.add_child(node);node.position=Vector2(x,y);node.size=Vector2(w,h);return node
func panel(parent: Node,x: float,y: float,w: float,h: float,color: Color) -> ColorRect:
	var p=ColorRect.new();p.color=color;place(p,parent,x,y,w,h);return p
func label(parent: Node,value: String,x: float,y: float,w: float,h: float,font_size: int=21,color: Color=PAPER,serif=false) -> Label:
	var l=Label.new();l.text=value;l.add_theme_font_override("font",TITLE if serif else BODY)
	l.add_theme_font_size_override("font_size",font_size);l.add_theme_color_override("font_color",color)
	l.mouse_filter=Control.MOUSE_FILTER_IGNORE;place(l,parent,x,y,w,h);return l
func button(parent: Node,value: String,x: float,y: float,w: float,h: float,callback: Callable,primary=false) -> Button:
	var b=Button.new();b.text=value;b.add_theme_font_override("font",BODY);b.add_theme_font_size_override("font_size",20)
	b.add_theme_color_override("font_color",INK if primary else PAPER);b.add_theme_color_override("font_hover_color",INK if primary else Color.WHITE)
	b.add_theme_color_override("font_pressed_color",INK if primary else PAPER);b.add_theme_color_override("font_disabled_color",Color("88978d"))
	for state in ["normal","hover","pressed","disabled","focus"]:
		var style=StyleBoxFlat.new();style.bg_color=GOLD if primary else Color("2e4746")
		if state=="hover":style.bg_color=style.bg_color.lightened(0.12)
		if state=="disabled":style.bg_color=Color("273c3b")
		style.set_corner_radius_all(5);style.content_margin_left=12;style.content_margin_right=12
		if state=="focus":style.set_border_width_all(2);style.border_color=PAPER;style.draw_center=false
		b.add_theme_stylebox_override(state,style)
	place(b,parent,x,y,w,h);b.pressed.connect(callback)
	b.gui_input.connect(func(event): disabled_button_input(b,event))
	return b
func logo(parent: Node,x: float,y: float,w: float,h: float):
	var art=TextureRect.new();art.texture=LOGO;art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;art.mouse_filter=Control.MOUSE_FILTER_IGNORE
	place(art,parent,x,y,w,h)
func build_ui():
	map=MapView.new();map.engine=engine;map.texts=texts;place(map,self,0,92,1280,474);map.cell_tapped.connect(on_cell);map.fire_sound.connect(play_combat_sound);map.assault_sound.connect(play_assault_sound)
	header=panel(self,0,0,1280,92,INK)
	logo(header,14,14,188,64)
	label(header,t("subtitle"),216,8,728,31,23,PAPER,true)
	turn_label=label(header,"",216,44,410,36,26,GOLD)
	score_label=label(header,"",652,48,296,29,20)
	header_buttons.append(button(header,t("journal"),960,22,106,50,show_journal))
	header_buttons.append(button(header,t("help"),1075,22,85,50,show_help))
	header_buttons.append(button(header,t("menu"),1169,22,94,50,show_menu))
	hint_bar=panel(self,0,530,1280,36,Color("d6d9bd"));hint=label(hint_bar,t("hint_select"),22,2,1236,32,18,INK)
	hint_bar.hide()
	footer=panel(self,0,540,1280,180,INK)
	unit_card=panel(footer,12,6,486,168,Color("253e3e"))
	action_card=panel(footer,510,6,486,168,Color("253e3e"))
	unit_flag=TextureRect.new();unit_flag.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;unit_flag.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;unit_flag.mouse_filter=Control.MOUSE_FILTER_IGNORE
	place(unit_flag,footer,22,12,30,22)
	unit_label=label(footer,"",62,8,263,28,23,PAPER,true);unit_label.clip_text=true
	unit_info=label(footer,"",22,42,250,29,24,PAPER);unit_info.clip_text=true
	weapon_label=label(footer,"",22,120,246,24,18,Color("d4decf"))
	unit_state=label(footer,"",22,84,425,25,20,GOLD)
	unit_reaction=label(footer,"",276,120,163,24,18,Color("d4decf"))
	formation_button=button(footer,"",758,97,226,49,show_formations,true);formation_button.add_theme_font_size_override("font_size",18)
	formation_label=label(footer,"",304,84,135,25,19,Color("d4decf"));formation_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	terrain_label=label(footer,"",334,10,105,26,20,GOLD);terrain_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	unit_ap=label(footer,"",279,42,158,28,24,GOLD)
	unit_ap.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	unit_reaction.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	ammo_label=label(footer,"",22,121,462,24,20,GOLD)
	support_label=label(footer,"",310,97,178,51,19,Color("d4decf"))
	support_label.add_theme_constant_override("line_spacing",0)
	supply_label=label(footer,"",310,123,176,24,19,Color("d4decf"))
	for field in [support_label,supply_label]:
		field.mouse_filter=Control.MOUSE_FILTER_STOP
		field.gui_input.connect(func(event):
			if (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed):
				show_link_info(field==support_label);field.accept_event())
	encircled_label=label(footer,"",310,147,178,24,19,GOLD)
	context_label=label(footer,"",486,12,504,32,22,GOLD);context_label.clip_text=true
	context_detail=label(footer,"",486,50,504,45,20)
	context_detail.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	context_detail.max_lines_visible=3
	context_detail.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	for field in [unit_state,formation_label,terrain_label,unit_ap,weapon_label,ammo_label,support_label,supply_label,unit_reaction,encircled_label]:field.clip_text=true
	actions.undo=button(footer,t("undo"),486,103,261,42,undo_move,true)
	var undo_disabled=actions.undo.get_theme_stylebox("disabled").duplicate()
	undo_disabled.set_border_width_all(1);undo_disabled.border_color=Color("718379")
	actions.undo.add_theme_stylebox_override("disabled",undo_disabled)
	actions.undo.add_theme_color_override("font_disabled_color",Color("bac6bb"))
	actions.rally=button(footer,t("rally"),486,103,261,42,commit_rally,true)
	actions.assault=button(footer,t("assault"),486,103,261,42,commit_assault,true)
	actions.entrench=button(footer,t("entrench"),486,103,261,42,commit_entrench,true)
	actions.deploy=button(footer,t("deploy"),802,97,182,49,change_deployment,true)
	actions.end_turn=button(footer,t("end_turn"),1011,14,251,54,primary_action,true)
	actions.next=button(footer,t("next"),1011,80,251,48,next_unit)
	status=label(footer,"",1011,129,251,21,12,Color("b0c4ad"))
	resized.connect(layout);layout()
func layout():
	if map==null:return
	var extra=size-Vector2(1280,720)
	map.size=Vector2(size.x,448+extra.y);header.size.x=size.x;footer.size.x=size.x
	footer.position.y=540+extra.y;hint_bar.position.y=504+extra.y;hint_bar.size.x=size.x;hint.size.x=size.x-44
	for k in range(header_buttons.size()):header_buttons[k].position.x=[960,1075,1169][k]+extra.x
	for key in ["end_turn","next"]:actions[key].position.x=1011+extra.x
	status.position.x=1011+extra.x
	layout_cards()
	if is_instance_valid(modal):
		modal.size=size;modal.get_child(0).size=size
		if is_instance_valid(modal_box):modal_box.position=(size-modal_box.size)/2
func layout_cards():
	if unit_card==null or context_label==null:return
	var w=(size.x-308.0)/2.0;var x=24.0+w
	unit_card.size=Vector2(w,168);action_card.position=Vector2(x,6);action_card.size=Vector2(w,168)
	unit_label.size.x=w-203 if unit_flag.visible else w-24
	terrain_label.position.x=12+w-138;terrain_label.size.x=128
	unit_info.position.y=38;unit_ap.position=Vector2(12+w-180,38)
	unit_info.size.x=w-24 if unit_ap.text.is_empty() else w-198
	unit_ap.size.x=168
	unit_state.position.y=70;formation_label.position=Vector2(12+w-155,70)
	unit_state.size.x=w-175 if formation_label.visible else w-24
	var has_support=not support_label.text.is_empty()
	weapon_label.position=Vector2(22,98);weapon_label.size=Vector2(w-214 if has_support else w-24,24)
	ammo_label.position=Vector2(22,123);ammo_label.size=Vector2(w-214 if has_support else w-24,24)
	unit_reaction.position=Vector2(22,147);unit_reaction.size=Vector2(w-214 if has_support else w-24,24)
	unit_reaction.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
	support_label.position=Vector2(12+w-186,98);support_label.size=Vector2(176,24)
	supply_label.position=Vector2(12+w-186,123);supply_label.size=Vector2(176,24)
	encircled_label.position=Vector2(12+w-186,147);encircled_label.size=Vector2(176,24)
	# All right-column text shares the same right edge, including each support line.
	var right_edge=unit_card.position.x+w-12
	for field in [terrain_label,unit_ap,formation_label,support_label,supply_label,encircled_label]:
		field.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
		field.position.x=right_edge-field.size.x
	context_label.position=Vector2(x+12,12);context_label.size=Vector2(w-24,32)
	context_detail.position=Vector2(x+12,51);context_detail.size=Vector2(w-24,70)
	var bw=(w-34)/2.0
	for key in ["rally","assault","entrench"]:actions[key].position=Vector2(x+12,123);actions[key].size=Vector2(bw,45)
	formation_button.position=Vector2(x+w-12-bw,123);formation_button.size=Vector2(bw,45)
	actions.deploy.position=formation_button.position;actions.deploy.size=formation_button.size
	# Undo has a fixed, discoverable place even when the last action is irreversible.
	actions.undo.position=Vector2(x+w-12-bw,10);actions.undo.size=Vector2(bw,40)
	actions.undo.add_theme_font_size_override("font_size",18)
	if actions.undo.visible:context_label.size.x=bw
	context_label.visible=true
	# The heading never draws into the upper action's reserved rectangle.
	var heading_size=22
	while heading_size>16 and BODY.get_string_size(context_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,heading_size).x>context_label.size.x:heading_size-=1
	context_label.add_theme_font_size_override("font_size",heading_size)
func camp(side: int) -> String:return t("france") if side==0 else t("germany")
func ap_text(value) -> String:
	var v=float(value)/4.0;return str(int(v)) if is_equal_approx(v,roundf(v)) else str(v).replace(".",",")
func clear_preview():route=[];full_route=[];target=-1;inspected=-1;inspected_report=-1
var combat_report_ttl=0.0
func terrain_caption(i: int) -> String:
	var name=t("terrain_short_"+str(engine.pack.map.tiles[i]))
	return t("terrain_hill") if engine.pack.map.get("show_relief",true) and (engine.elevation(i)>=2 or engine.pack.terrains[engine.pack.map.tiles[i]].get("height_category",false)) else name
var support_notice_seen=0
func refresh(message: String=""):
	var recent_support=[]
	for event in engine.state.get("support_events",[]):
		if int(event.serial)>support_notice_seen and int(event.side)==int(engine.state.human_side):recent_support.append(event)
	support_notice_seen=int(engine.state.get("support_serial",0))
	if not recent_support.is_empty():
		var event=recent_support[-1]
		for entry in recent_support:
			if entry.kind=="surrender":event=entry
		var text=t("support_surrender_notice")%[t(event.name_key),int(event.prisoners)] if event.kind=="surrender" else t("support_cut_notice")%t(event.name_key)
		map.show_feedback(engine.index(Vector2i(int(event.cell[0]),int(event.cell[1]))),text)
	combat_report_ttl=0.0
	if engine.fixed_hq():
		for u in engine.state.units:
			if int(u.side)!=int(engine.state.human_side) or not u.get("is_hq",false):continue
			var group=str(u.command_group)
			if hq_seen.has(group) and hq_seen[group]!=u.id:pending_hq_notice=t("hq_transfer")%t(str(u.name_key)+"_short")
			hq_seen[group]=u.id
		if human_turn() and target<0 and route.is_empty() and not pending_hq_notice.is_empty():
			message=pending_hq_notice;pending_hq_notice=""
	if selected>=0 and not engine.visible_to(int(engine.state.human_side),selected):selected=-1
	if target>=0 and not engine.visible_to(int(engine.state.human_side),target):target=-1
	if inspected_report>=0 and engine.contact(inspected_report,int(engine.state.human_side)).is_empty():inspected_report=-1
	map.selected=selected;map.target=target;map.route=route;map.full_route=full_route
	map.reachable=engine.reach(selected).costs if selected>=0 else {}
	map.fire_cells=engine.artillery_fire_cells(selected) if human_turn() and selected>=0 and int(engine.state.units[selected].side)==int(engine.state.human_side) else {}
	map.queue_redraw()
	turn_label.text=t("playing_camp")%camp(int(engine.state.side))+" · "+t("you" if human_turn() else "ai")
	var minute=(int(engine.state.turn)-(0 if engine.state.finished else 1))*int(engine.pack.rules.minutes)
	score_label.text=t("time")%[int(engine.pack.rules.start_hour)+minute/60,minute%60]+"   ·   "+t("turn")%[engine.state.turn,engine.pack.rules.turns]
	# A target is inspected without changing the acting unit or its orders.
	var shown=target if target>=0 and engine.alive(target) else selected
	unit_label.add_theme_font_size_override("font_size",23)
	ammo_label.text="";support_label.text="";supply_label.text="";encircled_label.text=""
	unit_label.tooltip_text="";unit_label.text=t("unit_none");unit_info.text=t("unit_prompt");unit_ap.text="";terrain_label.text="";weapon_label.text="";unit_state.text="";unit_reaction.text=""
	formation_button.hide();formation_label.hide();unit_state.size.x=425
	unit_flag.visible=shown>=0
	unit_label.position.x=62 if shown>=0 else 22
	unit_label.size.x=263 if shown>=0 else 425
	unit_info.add_theme_font_size_override("font_size",24 if shown>=0 else 19)
	unit_info.size.x=250 if shown>=0 else 415
	unit_info.autowrap_mode=TextServer.AUTOWRAP_OFF if shown>=0 else TextServer.AUTOWRAP_WORD_SMART
	unit_info.size.y=29 if shown>=0 else 58
	weapon_label.add_theme_font_size_override("font_size",18);weapon_label.size.x=246;unit_reaction.position.x=276;unit_reaction.size.x=163;unit_reaction.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	weapon_label.visible=true;terrain_label.visible=shown>=0
	if shown>=0:
		var u=engine.state.units[shown];unit_label.text=unit_heading(shown);unit_flag.texture=FLAGS[int(u.side)]
		terrain_label.text=terrain_caption(engine.unit_cell(u))
		unit_info.text=t("unit_strength")%[u.strength,u.initial_strength]
		weapon_label.text=t("cavalry_weapon_info") if engine.cavalry(shown) else t("weapon_info")%[t(engine.weapon(shown).get("short_name_key",engine.weapon(shown).name_key)),engine.weapon(shown).range]
		unit_state.add_theme_color_override("font_color",PAPER if u.morale=="stable" else Color("f3bf72"))
		unit_state.text=t("morale_"+u.morale)+( " · "+t("unit_shelter") if u.get("entrenched",false) else "")
		unit_reaction.text=t("cavalry_contact") if engine.cavalry(shown) else t("reaction_routed" if u.morale=="routed" else "reaction_limbered" if engine.artillery(shown) and not u.deployed else "reaction_ready" if int(u.reactions)>0 else "reaction_spent")
		unit_ap.text=t("unit_ap")%[ap_text(u.ap),ap_text(engine.max_ap(shown))]
		if not engine.artillery(shown) and not engine.cavalry(shown) and not engine.headquarters(shown):
			unit_state.size.x=274
			var editable=shown==selected and target<0 and human_turn() and int(u.side)==int(engine.state.side) and not engine.state.finished
			var formation_text=t("formation_"+engine.formation(shown))
			formation_button.visible=editable;formation_label.visible=true
			formation_button.text=t("formation_button")%formation_text;formation_label.text=formation_text
			formation_button.disabled=not engine.can_act(shown) or u.morale=="routed" or int(u.ap)<int(engine.pack.rules.formations.change_ap) or map.busy()
	if engine.fog_enabled() and not engine.state.finished:
		if shown>=0 and int(engine.state.units[shown].side)!=int(engine.state.human_side):show_enemy_report(shown)
		elif inspected_report>=0:show_enemy_report(inspected_report)
	if shown>=0 and engine.support_enabled() and int(engine.state.units[shown].side)==int(engine.state.human_side):
		var u=engine.state.units[shown]
		ammo_label.text=t("ammo_na") if engine.cavalry(shown) else t("ammo_status")%t("ammo_"+str(u.ammo_level))
		if u.encircled:encircled_label.text=t("support_encircled")
		support_label.text=t("command_status")%t("link_ok" if u.command_ok else "command_cut")
		supply_label.text=t("supply_status")%t("link_ok" if u.supply_ok else "link_cut")
		ammo_label.add_theme_color_override("font_color",Color("f3bf72") if int(u.ammo_level)==2 else PAPER)
		support_label.add_theme_color_override("font_color",Color("c6d0bc") if u.command_ok else Color("f3bf72"))
		supply_label.add_theme_color_override("font_color",Color("c6d0bc") if u.supply_ok else Color("f3bf72"))
	show_terrain_info()
	terrain_label.add_theme_font_size_override("font_size",14 if terrain_label.text.length()>12 else 21)
	context_label.size.x=504
	context_label.text=t("available")%engine.available_count();context_detail.text=t("objectives_hint" if engine.objective_definitions().size()>1 else "objective_hint")
	if engine.cavalry(selected):context_detail.text=t("hint_cavalry")%ap_text(engine.assault_cost(selected))
	if engine.artillery(selected):
		context_label.text=t("deployed" if engine.state.units[selected].deployed else "limbered")
		context_detail.text=t("hint_artillery_clear") if not map.fire_cells.is_empty() else t("hint_artillery")
	if not route.is_empty():
		context_label.text=t("route_cost_short")%ap_text(engine.path_cost(route,selected))
		context_detail.text=t("route_remaining")%ap_text(int(engine.state.units[selected].ap)-engine.path_cost(route,selected))+"\n"+(t("route_limit") if full_route.size()>route.size() else t("route_confirm"))
		if engine.path_has_river(route):context_detail.text=t("river_preview")+"\n"+t("route_confirm")
	elif full_route.size()>1:
		context_label.text=t("no_step");context_detail.text=t("route_cancel")
	elif target>=0:
		context_label.text=t("acting_cavalry" if engine.cavalry(selected) else "acting_shooter")%t(engine.state.units[selected].name_key)
		var reason=engine.fire_status(selected,target)
		if not engine.cavalry(selected):context_label.text=t("fire_preview_ok" if reason=="ok" else "fire_preview_blocked")
		context_detail.text=(t("charge_confirm")%ap_text(engine.assault_cost(selected)) if engine.assault_status(selected,target)=="ok" else t("charge_no_ap")%ap_text(engine.assault_cost(selected)) if engine.assault_status(selected,target)=="no_ap" else t("assault_"+engine.assault_status(selected,target))) if engine.cavalry(selected) else t("fire_confirm") if reason=="ok" else t("fire_"+reason)
	var ours=not engine.state.finished and selected>=0 and int(engine.state.units[selected].side)==int(engine.state.side) and human_turn()
	actions.deploy.visible=ours and engine.artillery(selected) and engine.state.units[selected].morale!="routed" and (target<0 or not engine.state.units[selected].deployed)
	if actions.deploy.visible:
		actions.deploy.text=t("limber" if engine.state.units[selected].deployed else "deploy")
		actions.deploy.disabled=not engine.can_act(selected) or int(engine.state.units[selected].ap)<int(engine.weapon(selected).deployment_ap) or map.busy()
	actions.rally.visible=ours and engine.state.units[selected].morale!="stable" and target<0
	if actions.rally.visible:
		actions.rally.text=t("rally_cost")%ap_text(engine.rally_cost(selected))
		actions.rally.disabled=engine.rally_status(selected)!="ok" or map.busy()
		context_label.text=t("morale_"+engine.state.units[selected].morale);context_detail.text=t("rally_"+engine.rally_status(selected))
		if engine.rally_status(selected) in ["ok","no_ap"]:context_detail.text=context_detail.text%ap_text(engine.rally_cost(selected))
	actions.assault.visible=ours and target>=0 and not engine.artillery(selected) and engine.distance(engine.unit_cell(engine.state.units[selected]),engine.unit_cell(engine.state.units[target]))==1
	actions.assault.text=t("charge")%ap_text(engine.assault_cost(selected)) if engine.cavalry(selected) else t("assault")
	actions.assault.disabled=engine.assault_status(selected,target)!="ok" or map.busy() if actions.assault.visible else true
	actions.entrench.visible=ours and not engine.cavalry(selected) and target<0 and route.is_empty() and full_route.is_empty() and not actions.rally.visible and not engine.state.units[selected].get("entrenched",false) and (not engine.artillery(selected) or engine.state.units[selected].deployed)
	actions.entrench.disabled=engine.entrench_status(selected)!="ok" or map.busy() if actions.entrench.visible else true
	if actions.entrench.visible and not engine.artillery(selected):context_detail.text=t("entrench_"+engine.entrench_status(selected))
	if ours and target<0 and route.is_empty() and full_route.is_empty() and engine.state.units[selected].get("entrenched",false):context_label.text=t("entrenched");context_detail.text=t("entrenched_hint")
	var can_undo=not engine.state.finished and not engine.previous.is_empty() and human_turn() and not map.busy()
	actions.undo.visible=human_turn() and not engine.state.finished
	if can_undo and target<0:context_label.text=t("undo_available")
	actions.undo.disabled=not can_undo
	actions.next.disabled=engine.available_count()==0 or not human_turn() or map.busy()
	actions.end_turn.text=t("results" if engine.state.finished else "end_turn")
	actions.end_turn.disabled=map.busy() or (not engine.state.finished and not human_turn())
	actions.next.visible=not engine.state.finished
	if ours and target<0 and route.is_empty() and engine.state.units[selected].get("river_halt",false):context_detail.text=t("river_halt")
	if not human_turn():context_label.text=t("ai_playing");context_detail.text=t("ai_detail")
	if engine.state.finished:
		turn_label.text=t("battle_finished");context_label.text=t("result_"+engine.result_for(int(engine.state.human_side)).level);context_detail.text=t("inspection_hint")
	if message!="":
		hint.text=message
		if route.is_empty() and full_route.is_empty() and target<0 and human_turn() and not actions.rally.visible and not (selected>=0 and engine.artillery(selected) and engine.state.units[selected].deployed):context_detail.text=message
	layout_cards()
func on_cell(i: int):
	if not playing or is_instance_valid(modal) or i<0 or map.busy():return
	inspected_report=-1
	var n=engine.known_unit_at(i,int(engine.state.human_side))
	if n<0 and engine.fog_enabled() and not engine.state.finished:
		var old=engine.contact_at(i,int(engine.state.human_side))
		if old>=0:selected=-1;clear_preview();inspected_report=old;refresh();return
	if engine.state.finished:
		if n>=0:selected=-1 if selected==n else n;clear_preview()
		else:selected=-1;clear_preview();inspected=i
		refresh();return
	if not human_turn():return
	if n>=0:
		if n==selected:
			selected=-1;clear_preview();refresh(t("hint_cancel"));return
		if selected>=0 and int(engine.state.units[selected].side)==int(engine.state.side) and int(engine.state.units[n].side)!=int(engine.state.side):
			if target==n:
				if engine.cavalry(selected) and engine.assault_status(selected,target)=="ok":commit_assault()
				elif engine.fire_status(selected,target)=="ok":commit_fire()
				else:refresh()
				return
			route=[];full_route=[];target=n;inspected=-1;refresh(t("hint_target"));return
		selected=n;clear_preview();refresh(t("hint_path") if engine.can_act(n) else t("hint_enemy") if int(engine.state.units[n].side)!=int(engine.state.side) else t("hint_done"));return
	inspected=i
	if selected<0:refresh();return
	# Confirmation applies only to the reachable endpoint, never to the remote request.
	if route.size()>1 and i==int(route[-1]):commit_move();return
	target=-1
	var preview=engine.preview(selected,i);route=preview.route;full_route=preview.full
	refresh(t("hint_limit") if full_route.size()>route.size() and full_route.size()>1 else t("hint_confirm") if route.size()>1 else t("hint_invalid"))
func persist():
	has_save=saver.save_game(engine);status.text=t("saved" if has_save else "save_error")
func commit_move():
	var was_halted=bool(engine.state.units[selected].get("river_halt",false))
	var result=engine.move(selected,route)
	if not was_halted and engine.state.units[selected].get("river_halt",false):map.animate_crossing(selected)
	clear_preview();persist()
	refresh(t("fog_move") if result=="discovered" else t("hint_capture") if result=="capture" else t("river_halt") if result=="moved" and engine.state.units[selected].get("river_halt",false) else t("hint_moved") if result=="moved" else t("hint_invalid"))
func undo_move():
	if human_turn() and not map.busy() and engine.undo():map.crossing_ttl=0;clear_preview();persist();refresh(t("hint_undo"))
func commit_fire():
	if target<0 or map.busy():return
	perform_fire(selected,target)
func commit_assault():
	if not human_turn() or target<0 or map.busy():return
	perform_assault(selected,target)
func perform_fire(shooter: int,victim: int):
	var result=engine.fire(shooter,victim)
	if result.status!="ok":refresh(t("fire_"+result.status));return
	present_combat(result.event)
func perform_assault(attacker: int,victim: int):
	var result=engine.assault(attacker,victim)
	if result.status!="ok":refresh(t("assault_"+result.status));return
	present_combat(result.event)
func combat_summary(event: Dictionary) -> String:
	var own=int(event.return_loss) if int(event.side)==int(engine.state.human_side) else int(event.loss)
	var other=int(event.loss) if int(event.side)==int(engine.state.human_side) else int(event.return_loss)
	var amount=str(other)
	if engine.fog_enabled() and not engine.state.finished:
		var low=0 if other==0 else floori(float(other-1)/25)*25
		amount=t("loss_estimated")%[low,0 if other==0 else low+25]
	var result=t("loss_report")%[amount,own]
	if event.get("reaction",false):result+=" · "+t("reply_cannon" if event.get("reaction_cannon",false) else "reply_rifle")
	if event.get("intercepted",false):result+=" · "+t("fog_intercepted")
	if event.kind in ["assault","charge"]:result+=" · "+t("outcome_"+event.outcome)
	return result
func present_combat(event: Dictionary):
	if not human_turn():
		var a=engine.index(Vector2i(event.from[0],event.from[1]));var b=engine.index(Vector2i(event.to[0],event.to[1]))
		map.focus=(map.world(a)+map.world(b))/2;map.clamp_focus()
	var shown=event.duplicate(true)
	if engine.fog_enabled() and not engine.state.finished:
		if int(event.side)==int(engine.state.human_side):shown.retreat=[]
		else:shown.attacker_retreat=[];shown.advance=[]
	map.animate_fire(shown,"",event.cannon)
	clear_preview();persist();refresh()
	show_combat_report(event)
func show_combat_report(event: Dictionary):
	# Only the player's own morale is shown: never disclose a hidden enemy state.
	if event.is_empty():return
	var own_attacks=int(event.side)==int(engine.state.human_side)
	var old_state=str(event.attacker_old_morale if own_attacks else event.old_morale)
	var new_state=str(event.attacker_new_morale if own_attacks else event.new_morale)
	var eliminated=bool(event.attacker_eliminated if own_attacks else event.eliminated)
	var other=int(event.loss) if own_attacks else int(event.return_loss)
	var own=int(event.return_loss) if own_attacks else int(event.loss)
	var amount=str(other)
	if engine.fog_enabled() and not engine.state.finished:
		var low=0 if other==0 else floori(float(other-1)/25)*25
		amount=t("loss_estimated")%[low,0 if other==0 else low+25]
	var lines=[t("combat_losses_short")%[amount,own]]
	var reply=t("reply_cannon" if event.get("reaction_cannon",false) else "reply_rifle") if event.get("reaction",false) else t("combat_no_reply")
	if event.kind in ["assault","charge"]:reply+=" · "+t("outcome_"+event.outcome)
	lines.append(reply)
	if eliminated:lines.append(t("combat_own_eliminated"))
	elif new_state!=old_state:lines.append(t("combat_own_state")%t("morale_"+new_state))
	elif event.get("intercepted",false):lines.append(t("fog_intercepted"))
	combat_report_ttl=1.3
	context_label.text=t("combat_report_title")
	context_detail.text="\n".join(lines)
	layout_cards()
func play_combat_sound(is_cannon: bool,is_reaction: bool):
	if not sound_enabled or app_suspended:return
	var key="cannon" if is_cannon else "rifle"
	if engine.state.events.size()%2==0:key+="_alt"
	var player=reaction_player if is_reaction else sound_player
	player.stream=sound_streams[key];player.play()
func show_enemy_report(n: int):
	unit_label.tooltip_text=""
	var side=int(engine.state.human_side);var record=engine.contact(n,side)
	if record.is_empty():return
	var current=engine.visible_to(side,n);var c=record.cell;var pos=engine.index(Vector2i(int(c[0]),int(c[1])))
	unit_flag.show();unit_flag.texture=FLAGS[1-side];unit_label.position.x=62;unit_label.size.x=263;unit_label.add_theme_font_size_override("font_size",21)
	var key=str(record.name_key)+"_short" if int(record.level)==2 and texts.has(str(record.name_key)+"_short") else str(record.name_key)
	unit_label.text=t(key);terrain_label.show();terrain_label.text=terrain_caption(pos)
	unit_info.text=(t("fog_exact")%int(record.exact_strength) if record.has("exact_strength") else t("fog_estimate")%[int(record.low),int(record.high)]) if current else t("fog_strength_hidden");unit_info.size.x=415;unit_info.add_theme_font_size_override("font_size",21)
	unit_ap.text=""
	formation_button.hide();formation_label.hide();unit_state.size.x=415
	unit_state.text=t("morale_"+str(record.morale)) if current and int(record.level)==2 else t("fog_no_state") if current else t("fog_old")%int(record.turn)
	weapon_label.text=t("fog_identified" if int(record.level)==2 else "fog_spotted") if current else t("fog_contact");weapon_label.size.x=220
	unit_reaction.text=t("fog_no_ap_info")
func show_terrain_info():
	if inspected<0:return
	var key=engine.pack.map.tiles[inspected];var data=engine.pack.terrains[key]
	var cover="none" if float(data.fire_received)>=1 else "light" if float(data.fire_received)>.7 else "good" if float(data.fire_received)>.6 else "strong"
	var movement=t("impassable") if int(data.cost)<0 else t("ap")%ap_text(engine.movement_cost(selected,inspected))
	if selected<0:
		unit_label.text=t(str(engine.objective_at(inspected).get("name_key","objective"))) if not engine.objective_at(inspected).is_empty() else terrain_caption(inspected)
		if engine.pack.map.get("show_relief",true) and engine.elevation(inspected)>=2:unit_label.text=t("terrain_hill")
		unit_info.text=t("terrain_move")%movement;unit_info.size.y=29
		unit_state.text=t("terrain_protection")%t("cover_"+cover)
		weapon_label.size.x=415;weapon_label.text=(t("fog_current" if engine.cell_visible(int(engine.state.human_side),inspected) else "fog_unknown")+" · " if engine.fog_enabled() else "")+t(str(data.get("visibility_key","visibility_open")))
		unit_reaction.text=""
		if engine.fixed_hq():
			for c in engine.pack.rules.support.supply_sources[int(engine.state.human_side)]:
				if inspected==engine.index(Vector2i(int(c[0]),int(c[1]))):
					unit_label.text=t("supply_zone");unit_info.text=terrain_caption(inspected);unit_state.text=t("supply_zone_detail")
		if not engine.objective_at(inspected).is_empty():
			var owner=engine.objective_owner(engine.objective_at(inspected))
			unit_label.text+=" · "+(t("fr_short") if owner==0 else t("de_short") if owner==1 else t("neutral"))
			unit_info.text+= " · ★ "+str(int(engine.objective_at(inspected).points))
	else:
		weapon_label.text=t("terrain_route_cost")%[terrain_caption(inspected),movement]
		unit_reaction.text=t("terrain_protection")%t("cover_"+cover)
	for edge in engine.pack.map.get("river_edges",[]):
		if edge.has("bridge_from_turn") and inspected in [int(edge.a),int(edge.b)]:
			weapon_label.size.x=425;weapon_label.add_theme_font_size_override("font_size",16);unit_reaction.text=""
			weapon_label.text=t("bridge_wait")%int(edge.bridge_from_turn) if engine.open_river(int(edge.a),int(edge.b)) else t("bridge_open_notice")
func show_link_info(command: bool):
	var n=target if target>=0 else selected
	if n<0 or not engine.fixed_hq() or int(engine.state.units[n].side)!=int(engine.state.human_side):return
	var u=engine.state.units[n]
	var box=modal_base(800,392)
	label(box,t("link_title_command" if command else "link_title_supply"),30,20,740,38,27,GOLD,true)
	var content=t("link_"+("command_"+str(u.get("command_reason","ok")) if command else "supply_"+str(u.get("supply_reason","ok"))))
	if command:
		var leader=engine.unit_index(str(u.get("hq_id","")))
		if leader>=0:content+="\n\n"+t("hq_detail")%[t(str(engine.state.units[leader].name_key)+"_short"),int(engine.pack.rules.support.cavalry_command_radius if engine.cavalry(n) else engine.pack.rules.support.command_radius)]
		content+="\n\n"+t("command_effect_strict" if engine.strict_links() else "command_effect")
	else:content+="\n\n"+t("supply_effect")
	if engine.pack.rules.support.has("isolation_surrender_turns") and not u.get("command_ok",true) and not u.get("supply_ok",true):content+="\n\n"+t("isolation_count")%[int(u.get("isolation_turns",0)),int(engine.pack.rules.support.isolation_surrender_turns)]
	scroll_text(box,content,72,232)
	button(box,t("close"),30,326,740,48,close_modal,true)
func play_assault_sound():
	if sound_enabled and not app_suspended:assault_player.stream=sound_streams.assault;assault_player.play()
func commit_entrench():
	if human_turn() and not map.busy() and engine.entrench(selected):clear_preview();persist();refresh(t("hint_entrenched"))
func commit_rally():
	if human_turn() and not map.busy() and engine.rally(selected):clear_preview();persist();refresh(t("hint_rallied"))
func change_deployment():
	if engine.toggle_deployment(selected):
		clear_preview();persist();refresh(t("hint_deployed" if engine.state.units[selected].deployed else "hint_limbered"))
func next_unit():
	for offset in range(1,engine.state.units.size()+1):
		var n=(maxi(selected,-1)+offset)%engine.state.units.size()
		if engine.actionable(n):selected=n;clear_preview();map.focus=map.world(engine.unit_cell(engine.state.units[n]));refresh(t("hint_path"));return
	refresh(t("hint_none"))
func close_modal():
	if is_instance_valid(modal):modal.hide();modal.queue_free();modal=null;modal_box=null
func modal_base(w: float,h: float) -> Control:
	map.cancel_interaction()
	close_modal();modal=Control.new();place(modal,self,0,0,size.x,size.y)
	panel(modal,0,0,size.x,size.y,Color(0.035,0.08,0.08,0.78));modal_box=panel(modal,(size.x-w)/2,(size.y-h)/2,w,h,INK)
	panel(modal_box,0,0,w,3,GOLD);return modal_box
func show_menu():
	if playing:persist()
	var box=modal_base(874,604)
	logo(box,38,22,798,237)
	label(box,t("subtitle"),40,277,794,41,31,PAPER,true).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label(box,t("badge"),40,323,794,25,17,GOLD).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label(box,t("intro"),40,375,794,35,21).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label(box,t(str(engine.pack.get("description_key","intro_detail")))+(" · "+t("difficulty_"+str(engine.state.ai_difficulty)) if has_save else ""),40,410,794,45,16,Color("b6c5b2")).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	button(box,t("music_on" if music_enabled else "music_off"),40,459,385,43,func():toggle_music();show_menu())
	button(box,t("sound_on" if sound_enabled else "sound_off"),449,459,385,43,func():toggle_sound();show_menu())
	button(box,t("continue") if has_save else t("start"),40,516,491,60,resume if has_save else show_camp_choice,true)
	button(box,t("again") if has_save else t("help"),550,516,284,60,confirm_new if has_save else show_help)
func resume():
	support_notice_seen=int(engine.state.get("support_serial",0))
	playing=true;close_modal();refresh(t("save_recovered") if saver.recovered else t("hint_select"))
	if engine.state.finished:show_result()
func new_game(side: int=0):
	invalidate_ai();hq_seen={};pending_hq_notice=""
	var raw=FileAccess.get_file_as_string("res://packs/1870/"+str(SCENARIOS[scenario_choice].pack))
	engine=EngineRules.new(JSON.parse_string(raw));map.engine=engine
	saver=SaveStore.new("user://"+str(SCENARIOS[scenario_choice].save),raw.sha256_text());legacy_game=false
	save_preferences()
	engine.new_game(side,difficulty_choice);support_notice_seen=int(engine.state.get("support_serial",0));selected=-1;clear_preview();playing=true;reset_map_view();map.feedback_ttl=0;map.combat_ttl=0;map.crossing_ttl=0;ai_clock=0
	close_modal();persist();refresh(t("hint_select"))
func confirm_new():confirm(t("new_confirm"),t("new_detail"),t("new_yes"),show_camp_choice,show_menu)
func primary_action():
	if engine.state.finished:show_result()
	else:confirm_end()
func confirm_end():
	if not human_turn() or map.busy():return
	if engine.available_count()>0:confirm(t("end_confirm"),t("end_detail")%engine.available_count(),t("end_yes"),end_side,close_modal)
	else:end_side()
func confirm(title: String,detail: String,yes: String,callback: Callable,back: Callable):
	var box=modal_base(794,300);label(box,title,30,25,734,45,25,PAPER,true);label(box,detail,30,96,734,55,20)
	button(box,t("cancel"),30,207,223,60,back);button(box,yes,273,207,491,60,callback,true)
func end_side():
	invalidate_ai()
	var before=engine.state.units.duplicate(true)
	var previous_turn=int(engine.state.turn)
	engine.end_side();selected=-1;clear_preview();close_modal();persist()
	var notice=""
	if human_turn() and engine.support_enabled() and not engine.state.finished:
		var cuts=0;var restored=0
		for n in range(engine.state.units.size()):
			var u=engine.state.units[n]
			if not engine.alive(n) or int(u.side)!=int(engine.state.human_side):continue
			if (before[n].get("command_ok",true) and not u.command_ok) or (before[n].get("supply_ok",true) and not u.supply_ok):cuts+=1
			elif (not before[n].get("command_ok",true) and u.command_ok) or (not before[n].get("supply_ok",true) and u.supply_ok):restored+=1
		if cuts>0:notice=t("support_notice_cut")%cuts
		elif restored>0:notice=t("support_notice_restored")%restored
	if human_turn() and int(engine.state.get("reinforcements_arrived",0))>0:notice=t("reinforcement_notice")%int(engine.state.reinforcements_arrived)
	if human_turn() and int(engine.state.get("reinforcements_arrived",0))>0:notice=t("reinforcement_notice")%int(engine.state.reinforcements_arrived)
	for edge in engine.pack.map.get("river_edges",[]):
		if int(edge.get("bridge_from_turn",0))>previous_turn and int(edge.get("bridge_from_turn",0))<=int(engine.state.turn):notice=t("bridge_open_notice")
	refresh(notice)
	if engine.state.finished:show_result()
func scroll_text(box: Control,value: String,y: float,h: float):
	var scroll=preload("res://war_engine/presentation/touch_scroll.gd").new();place(scroll,box,30,y,box.size.x-60,h);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	var content=RichTextLabel.new();content.fit_content=true;content.scroll_active=false;content.bbcode_enabled=false
	content.custom_minimum_size.x=box.size.x-90;content.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	content.add_theme_font_override("normal_font",BODY);content.add_theme_font_size_override("normal_font_size",21);content.add_theme_color_override("default_color",PAPER)
	content.text=value;content.mouse_filter=Control.MOUSE_FILTER_IGNORE;scroll.add_child(content)
func show_help(page: int=0):
	var box=modal_base(1060,648);label(box,t("help_title"),30,15,700,41,27,GOLD,true)
	button(box,t("sound_on" if sound_enabled else "sound_off"),795,15,235,41,func():toggle_sound();show_help(page))
	for k in range(3):button(box,t(["help_basics","help_terrain","help_fire"][k]),30+k*336,66,324,48,func():show_help(k),page==k)
	var content=""
	if page==0:content=t("help_basics_body")+("\n\n"+((t("help_support0822") if engine.pack.get("version","") in ["0.8.22","0.8.25","0.8.28","0.8.29","0.8.30","0.8.31","0.8.32","0.8.33","0.8.34","0.8.35"] else t("help_support0821")) if engine.pack.rules.get("support",{}).get("separate_hq",false) else t("help_support0820") if engine.fixed_hq() else t("help_support") if engine.relaxed_supply() else t("help_support_legacy")) if engine.support_enabled() else "")
	elif page==1:
		content=t("help_terrain_body")+"\n\n"
		if not engine.river_links.is_empty():content+=t("help_river")+"\n\n"
		for terrain in (["plain","road","forest","village","cultivated","hill"] if not engine.river_links.is_empty() else ["plain","road","forest","village","hill","water","bridge"]):
			if terrain=="hill" and not engine.pack.map.get("show_relief",true):continue
			if terrain=="hill" and engine.pack.get("version","")=="0.8.31":
				content+=t("terrain_hill")+"\n"+t("height_help0831")+"\n\n";continue
			var data=engine.pack.terrains[terrain]
			content+=t("terrain_"+terrain)+" — "+(t("impassable") if int(data.cost)<0 else t("terrain_cost")%ap_text(data.cost))+"\n"+t("terrain_effect_"+terrain)+"\n\n"
	else:
		var weapon_rules=[]
		for w in engine.pack.weapons.values():
			if not bool(w.get("can_fire",true)):continue
			weapon_rules.append(t("weapon_rule")%[t(w.name_key),w.range,ap_text(w.ap)])
		content=t("help_fire_body").replace("%s","\n".join(weapon_rules))
	if page==0 and engine.strict_links():content+="\n\n"+t("help_strict0833")
	scroll_text(box,content,132,424);button(box,t("close") if playing else t("menu"),30,579,1000,48,close_modal if playing else show_menu,true)
func show_journal():
	var box=modal_base(1040,630);label(box,t("journal"),30,18,980,42,27,GOLD,true)
	var content=t("journal_empty")
	if not engine.state.events.is_empty():
		content=""
		for k in range(engine.state.events.size()-1,-1,-1):
			var event=engine.state.events[k]
			var names=[engine.state.units[int(event.shooter)].name_key,engine.state.units[int(event.target)].name_key]
			if engine.fog_enabled() and not engine.state.finished:names=event.get("fog_names",{}).get(str(int(engine.state.human_side)),["fog_enemy_generic","fog_enemy_generic"])
			content+=t("journal_combat")%[event.turn,t(names[0]),t(names[1]),t("kind_"+event.kind)]
			content+="\n"+combat_summary(event)+"\n"+t("journal_reaction" if event.reaction else "journal_no_reaction")
			if event.prisoners>0 and (not engine.fog_enabled() or engine.state.finished):content+=" • "+t("combat_prisoners")%[camp(1-int(event.side)),event.prisoners]
			if event.attacker_prisoners>0 and (not engine.fog_enabled() or engine.state.finished):content+=" • "+t("combat_prisoners")%[camp(int(event.side)),event.attacker_prisoners]
			if not event.retreat.is_empty() or not event.attacker_retreat.is_empty():content+=" • "+t("retreat")
			content+="\n\n"

	for event in engine.state.get("support_events",[]):
		if int(event.side)!=int(engine.state.human_side):continue
		content+="\n"+t("support_journal_turn")%int(event.turn)+" · "+(t("support_surrender_notice")%[t(event.name_key),int(event.prisoners)] if event.kind=="surrender" else t("support_cut_notice")%t(event.name_key))
	if engine.objective_definitions().size()>1:content=t("scenario_help")+"\n\n"+content
	scroll_text(box,content,82,454);button(box,t("close"),30,555,980,52,close_modal,true)
func inspect_battle():
	selected=-1;clear_preview();close_modal();refresh()
func result_reason(result: Dictionary) -> String:
	if result.level=="draw":return t("result_reason_draw07")
	return t("result_reason_"+str(result.reason)+"07")%camp(int(result.winner))
func show_result():
	if not engine.state.finished:return
	var box=modal_base(1040,680)
	label(box,t("result_title"),38,15,964,33,25,GOLD,true)
	label(box,(t("result_player")%camp(int(engine.state.human_side)))+" · "+t("difficulty_"+str(engine.state.ai_difficulty)),38,52,964,28,19)
	var result=engine.result_for(int(engine.state.human_side))
	label(box,t("result_"+result.level),38,85,964,49,34,PAPER,true)
	var explanation=label(box,"",38,144,964,55,18,Color("c6d0bc"));explanation.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;explanation.text=result_reason(result)
	label(box,t("result_metric"),38,205,410,29,20,GOLD)
	label(box,camp(0),470,205,240,29,21,GOLD,true);label(box,camp(1),745,205,253,29,21,GOLD,true)
	var rows=[
		[t("result_final"),t("result_points")%result.parts[0][0],t("result_points")%result.parts[1][0]],
		[t("result_duration"),t("result_duration_value")%[result.parts[0][1],engine.state.scores[0],int(engine.pack.rules.turns)*int(engine.objective_value_total())],t("result_duration_value")%[result.parts[1][1],engine.state.scores[1],int(engine.pack.rules.turns)*int(engine.objective_value_total())]],
		[t("result_military"),t("result_loss_value")%[result.parts[0][2],engine.military_losses(1)],t("result_loss_value")%[result.parts[1][2],engine.military_losses(0)]],
		[t("result_total"),t("result_points")%result.totals[0],t("result_points")%result.totals[1]],
		[t("result_casualties"),str(engine.losses(0)),str(engine.losses(1))],
		[t("result_prisoners"),str(engine.prisoners(0)),str(engine.prisoners(1))],
		[t("result_loss_rate"),t("result_percent")%(100.0*engine.military_losses(0)/maxi(1,engine.initial_force(0))),t("result_percent")%(100.0*engine.military_losses(1)/maxi(1,engine.initial_force(1)))],
		[t("result_routed"),str(engine.routed_count(0)),str(engine.routed_count(1))]]
	for k in range(rows.size()):
		var color=GOLD if k==3 else PAPER
		label(box,rows[k][0],38,240+k*32,410,30,19,color)
		label(box,str(rows[k][1]).replace(".",","),470,240+k*32,240,30,20,color)
		label(box,str(rows[k][2]).replace(".",","),745,240+k*32,253,30,20,color)
	label(box,t("result_actions")%[engine.state.moves,engine.state.shots,engine.state.assaults],38,507,964,27,17,Color("c6d0bc"))
	button(box,t("battle_details"),38,535,964,44,show_battle_details)
	button(box,t("inspect_battle"),38,599,472,56,inspect_battle,true)
	button(box,t("again"),530,599,472,56,show_camp_choice)
func show_battle_details():
	if not engine.state.finished:return
	var box=modal_base(1040,650)
	label(box,t("battle_details"),38,15,964,38,25,GOLD,true)
	var lines=[]
	for goal in engine.objective_definitions():
		var owner=engine.objective_owner(goal)
		lines.append(t(str(goal.get("name_key","objective")))+" : "+(camp(owner) if owner in [0,1] else "—"))
	lines.append("")
	if not engine.state.has("battle_history"):lines.append(t("battle_details_legacy"))
	for event in engine.state.get("battle_history",[]):
		if event.kind=="capture":
			for goal in engine.objective_definitions():
				if goal.id==event.objective:lines.append("Tour %d — %s : %s"%[event.turn,t(str(goal.get("name_key","objective"))),camp(int(event.side))])
		else:
			var n=engine.unit_index(event.unit)
			if n>=0:lines.append("Tour %d — %s (%s) : %d prisonniers"%[event.turn,t(engine.state.units[n].name_key),camp(int(event.side)),event.prisoners])
	scroll_text(box,"\n".join(lines),72,470)
	button(box,t("close"),38,569,964,56,show_result,true)
func _notification(what):
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and map!=null:map.cancel_interaction()
	if what==NOTIFICATION_APPLICATION_PAUSED:
		app_suspended=true
		if map!=null:map.cancel_interaction()
		if sound_player!=null:sound_player.stop();reaction_player.stop();assault_player.stop()
		if music_player!=null:music_player.stream_paused=true
	elif what==NOTIFICATION_APPLICATION_RESUMED:
		app_suspended=false
		if music_player!=null:music_player.stream_paused=false
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT] and playing and saver!=null:persist()
	if what==NOTIFICATION_WM_GO_BACK_REQUEST:
		if is_instance_valid(modal) and playing:close_modal()
		else:show_menu()

func human_turn() -> bool:return not ai_enabled or int(engine.state.side)==int(engine.state.human_side)
func save_preferences():
	var prefs=ConfigFile.new();prefs.set_value("game","scenario",active_scenario());prefs.set_value("audio","enabled",sound_enabled);prefs.set_value("audio","music",music_enabled);prefs.save(prefs_path)
func toggle_sound():
	sound_enabled=not sound_enabled
	if not sound_enabled:sound_player.stop();reaction_player.stop();assault_player.stop()
	save_preferences()
func toggle_music():
	music_enabled=not music_enabled
	if music_enabled:music_player.play();music_player.stream_paused=app_suspended
	else:music_player.stop()
	save_preferences()
func saved_scenario(choice: String) -> Dictionary:
	if has_save and active_scenario()==choice:return {"engine":engine,"saver":saver,"legacy":legacy_game}
	var candidates=[[str(SCENARIOS[choice].pack),str(SCENARIOS[choice].save)]]
	var older={"historical":["legacy0828_regimental_trial.json","save_regimental0828.json"],"classic":["legacy0828_prototype.json","save_classic_v0822.json"],"three":["legacy0828_three_objectives.json","save_three_v0822.json"]}
	candidates.append(older[choice])
	if choice=="classic":candidates.append(["legacy0821.json","save_classic_v0821.json"]);candidates.append(["legacy0820.json","save_classic_v0820.json"]);candidates.append(["legacy0819.json","save_v0816.json"]);candidates.append(["legacy0818.json","save_v0816.json"])
	elif choice=="three":candidates.append(["legacy_three0821.json","save_three_v0821.json"]);candidates.append(["legacy_three0820.json","save_three_v0820.json"]);candidates.append(["legacy_three0819.json","save_three_v0819.json"])
	for entry in candidates:
		var raw=FileAccess.get_file_as_string("res://packs/1870/"+entry[0]);var candidate=EngineRules.new(JSON.parse_string(raw))
		var slot=SaveStore.new("user://"+entry[1],raw.sha256_text())
		if slot.load_game(candidate):return {"engine":candidate,"saver":slot,"legacy":entry[0].begins_with("legacy")}
	return {}
func resume_scenario():
	var saved=saved_scenario(scenario_choice)
	if saved.is_empty():return
	hq_seen={};pending_hq_notice=""
	invalidate_ai();engine=saved.engine;saver=saved.saver;legacy_game=saved.legacy;map.engine=engine;has_save=true
	selected=-1;clear_preview();map.combat_ttl=0;map.crossing_ttl=0;map.feedback_ttl=0
	reset_map_view()
	save_preferences();resume()
func show_camp_choice():
	var box=modal_base(874,660);logo(box,48,8,778,100)
	label(box,t("scenario_title"),40,120,794,36,28,GOLD,true).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	button(box,t("scenario_classic"),40,170,250,48,func():scenario_choice="classic";show_camp_choice(),scenario_choice=="classic")
	button(box,t("scenario_three"),312,170,250,48,func():scenario_choice="three";show_camp_choice(),scenario_choice=="three")
	button(box,t("scenario_historical"),584,170,250,48,func():scenario_choice="historical";show_camp_choice(),scenario_choice=="historical")
	if scenario_choice=="historical":label(box,t("historical_trial_short"),40,220,794,23,16).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label(box,t("difficulty_title"),40,243,794,30,22,GOLD).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var levels=["easy","medium","hard"]
	for k in range(3):
		var value=levels[k]
		button(box,t("difficulty_"+value),40+k*270,289,254,54,func():difficulty_choice=value;show_camp_choice(),difficulty_choice==value)
	var description=label(box,t("difficulty_"+difficulty_choice+"_detail"),40,357,794,62,19)
	description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;description.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	if not saved_scenario(scenario_choice).is_empty():button(box,t("resume_scenario"),40,427,794,38,resume_scenario)
	else:label(box,t("choose_detail"),40,430,794,28,18).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	button(box,t("choose_france"),40,475,385,64,func():new_game(0),true)
	button(box,t("choose_germany"),449,475,385,64,func():new_game(1),true)
	button(box,t("menu"),40,581,794,48,show_menu)
func _process(delta: float):
	if engine==null or map==null:return
	if music_player!=null:
		var target_volume=float(engine.pack.music.combat_volume_db if map.busy() else engine.pack.music.volume_db)
		music_player.volume_db=move_toward(music_player.volume_db,target_volume,delta*22.0)
	if combat_report_ttl>0:
		combat_report_ttl=maxf(0,combat_report_ttl-delta)
		if combat_report_ttl<=0 and not map.busy():refresh()
	if map.just_finished:
		map.just_finished=false;refresh()
		show_combat_report(map.combat_event)
	if ai_thread!=null and not ai_thread.is_alive():
		var result=ai_thread.wait_to_finish();ai_thread=null
		if result.generation==ai_generation:ai_pending=result.decision
	if not playing or app_suspended or is_instance_valid(modal) or engine.state.finished or human_turn():return
	if not ai_pending.is_empty():
		if map.busy():return
		var decision=ai_pending;ai_pending={};apply_ai_decision(decision);return
	if ai_thread!=null:return
	ai_clock+=delta
	if ai_clock<0.04:return
	ai_clock=0
	var visible=[]
	for n in range(engine.state.units.size()):
		if engine.visible_to(int(engine.state.side),n) and int(engine.state.units[n].side)!=int(engine.state.side):visible.append(n)
	var snapshot=engine.observation(int(engine.state.side),visible)
	ai_thread=Thread.new()
	var error=ai_thread.start(compute_ai.bind(snapshot,ai_generation))
	if error!=OK:
		ai_thread=null;ai_pending=ai.choose(snapshot)
func compute_ai(snapshot: Dictionary,generation: int) -> Dictionary:
	return {"generation":generation,"decision":ai.choose(snapshot)}
func invalidate_ai():
	ai_generation+=1;ai_pending={};ai_clock=0
func _exit_tree():
	if ai_thread!=null:ai_thread.wait_to_finish();ai_thread=null
func apply_ai_decision(decision: Dictionary):
	if decision.kind=="end":end_side();return
	var n=engine.unit_index(decision.unit);var success=false
	if n<0:end_side();return
	match decision.kind:
		"fire":
			var victim=engine.unit_index(decision.target)
			if engine.fire_status(n,victim)=="ok":perform_fire(n,victim);return
		"assault":
			var victim=engine.unit_index(decision.target)
			if engine.assault_status(n,victim)=="ok":perform_assault(n,victim);return
		"move":
			var was_halted=bool(engine.state.units[n].get("river_halt",false))
			success=engine.move(n,decision.path) in ["moved","capture","discovered"]
			if success and not was_halted and engine.state.units[n].get("river_halt",false):map.animate_crossing(n)
		"deploy","limber":success=engine.toggle_deployment(n)
		"rally":success=engine.rally(n)
		"rest":success=engine.rest(n)
		"formation":success=engine.change_formation(n,decision.formation)
		"entrench":success=engine.entrench(n)
	if not success:engine.hold(n)
	persist();refresh()

func show_formations():
	if selected<0 or target>=0 or not human_turn() or (engine.artillery(selected) or engine.cavalry(selected) or engine.headquarters(selected)) or engine.state.finished or map.busy():return
	var n=selected
	var box=modal_base(850,486)
	label(box,t("formation_title"),30,16,790,34,27,GOLD,true)
	label(box,t("formation_cost")%ap_text(engine.pack.rules.formations.change_ap),30,58,790,26,19)
	for k in range(3):
		var value=["line","column","skirmish"][k]
		var status_value=engine.formation_status(n,value)
		var b=button(box,t("formation_"+value),30,108+k*96,185,66,func():commit_formation(n,value),engine.formation(n)==value)
		b.disabled=status_value!="ok"
		b.set_meta("disabled_reason",t("action_already") if status_value=="already" else t("action_routed") if status_value=="routed" else t("action_no_ap")%ap_text(engine.pack.rules.formations.change_ap))
		var description=label(box,"",235,112+k*96,580,68,18)
		description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		description.text=t("formation_"+value+"_description")
	button(box,t("close"),30,416,790,48,close_modal)
func commit_formation(n: int,value: String):
	if n!=selected or not human_turn() or map.busy():return
	if engine.change_formation(n,value):
		clear_preview();close_modal();persist();refresh(t("formation_changed")%t("formation_"+value))

# Disabled buttons keep their muted appearance; a tap explains, never executes.
func disabled_button_input(b: Button,event: InputEvent):
	if not b.disabled:return
	var pressed=event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed
	pressed=pressed or (event is InputEventScreenTouch and event.pressed)
	if not pressed:return
	var reason=disabled_reason(b)
	if is_instance_valid(modal) and b.has_meta("disabled_reason"):
		var notice=modal_box.get_node_or_null("disabled_notice")
		if notice==null:
			notice=label(modal_box,"",30,382,790,28,18,GOLD);notice.name="disabled_notice"
		notice.text=reason
	else:context_detail.text=reason
	b.accept_event()
func disabled_reason(b: Button) -> String:
	if b.has_meta("disabled_reason"):return b.get_meta("disabled_reason")
	if map.busy():return t("action_wait")
	if not human_turn():return t("action_ai")
	if b==actions.next:return t("action_none")
	if b==actions.undo:return t("undo_"+engine.undo_status())
	if selected<0:return t("hint_select")
	var u=engine.state.units[selected]
	if b==actions.rally:
		var why=engine.rally_status(selected)
		return t("rally_no_ap")%ap_text(engine.rally_cost(selected)) if why=="no_ap" else t("rally_"+why)
	if b==actions.assault:
		var why=engine.assault_status(selected,target)
		return t("charge_no_ap")%ap_text(engine.assault_cost(selected)) if why=="no_ap" and engine.cavalry(selected) else t("assault_"+why)
	if b==actions.entrench:return t("entrench_"+engine.entrench_status(selected))
	if u.morale=="routed":return t("action_routed")
	if u.done or int(u.ap)==0:return t("action_done")
	if b==formation_button:return t("action_no_ap")%ap_text(engine.pack.rules.formations.change_ap)
	if b==actions.deploy:return t("action_no_ap")%ap_text(engine.weapon(selected).deployment_ap)
	return t("action_unavailable")
