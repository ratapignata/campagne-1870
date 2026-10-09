from pathlib import Path
import json
root=Path(__file__).resolve().parents[2]
p=root/'war_engine/presentation/main.gd';s=p.read_text()
s=s.replace('\tactions.rest=button(footer,t("rest"),850,12,126,40,commit_rest)\n','')
a=s.index('\tactions.rest.visible=');b=s.index('\t# The heading',a)
s=s[:a]+'\tcontext_label.visible=true\n'+s[b:]
a=s.index('func commit_rest():');b=s.index('func camp(',a);s=s[:a]+s[b:]
s=s.replace('font_size",17,','font_size",17,') # Individual text sizes below remain bounded by rows.
s=s.replace('246,24,17,Color("c6d0bc")','246,24,18,Color("d4decf")').replace('163,24,17,Color("c6d0bc")','163,24,18,Color("d4decf")')
s=s.replace('19,Color("c6d0bc")','19,Color("d4decf")')
s=s.replace('if map.just_finished:map.just_finished=false;refresh()','if map.just_finished:\n\t\tmap.just_finished=false;refresh()\n\t\tshow_combat_report(map.combat_event)')
s=s.replace('clear_preview();persist();refresh(t("hint_charge" if event.kind=="charge" else "hint_assault" if event.kind=="assault" else "hint_fired"))','clear_preview();persist();refresh()\n\tshow_combat_report(event)')
idx=s.index('func play_combat_sound')
s=s[:idx]+'''func show_combat_report(event: Dictionary):
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
	context_label.text=t("combat_report_title")
	context_detail.text="\\n".join(lines)
	layout_cards()
''' +s[idx:]
p.write_text(s)
p=root/'war_engine/presentation/map_view.gd';s=p.read_text()
a='''			draw_string_outline(COUNTER_FONT,p+Vector2(-24,10)*z,"D",HORIZONTAL_ALIGNMENT_CENTER,maxf(34*z,15),maxi(14,int(37*z)),2,Color(0.08,0.14,0.14,0.9))
			draw_string(COUNTER_FONT,p+Vector2(-24,10)*z,"D",HORIZONTAL_ALIGNMENT_CENTER,maxf(34*z,15),maxi(14,int(37*z)),Color(0.98,0.82,0.48,0.94))'''
assert a in s;s=s.replace(a,'\t\t\tdisorder_badge(p,z)')
a='''			draw_string_outline(COUNTER_FONT,p+Vector2(-24,10)*z,"D",HORIZONTAL_ALIGNMENT_CENTER,maxf(34*z,15),maxi(14,int(37*z)),2,Color("162c31"))
			draw_string(COUNTER_FONT,p+Vector2(-24,10)*z,"D",HORIZONTAL_ALIGNMENT_CENTER,maxf(34*z,15),maxi(14,int(37*z)),Color("f9d17a"))'''
assert a in s;s=s.replace(a,'\t\t\tdisorder_badge(p,z)')
s+='''
func disorder_badge(p: Vector2,z: float):
	# A corner badge leaves the unit silhouette, number and strength visible.
	var badge=p+Vector2(-22,-17)*z
	draw_circle(badge,11*z,Color("172e32"))
	draw_arc(badge,10*z,0,TAU,24,Color("edc77b"),maxf(1,1.3*z),true)
	draw_string(COUNTER_FONT,badge+Vector2(-8,6)*z,"D",HORIZONTAL_ALIGNMENT_CENTER,16*z,maxi(10,int(17*z)),Color("ffe0a0"))
'''
p.write_text(s)
p=root/'packs/1870/fr.json';d=json.loads(p.read_text())
for k,v in d.items():
 if isinstance(v,str):d[k]=v.replace('0.8.16','0.8.17')
d['ammo_status']='Munitions : %s'
d['combat_report_title']='Bilan du combat'
d['combat_losses_short']='Pertes infligées : %s · subies : %d'
d['combat_no_reply']='Aucune riposte par tir'
d['combat_own_state']='Votre unité : %s'
d['combat_own_eliminated']='Votre unité hors de combat'
d['fire_limbered']='Canon non déployé : mettre en batterie.'
d['fire_blocked_terrain']='Ligne de tir bloquée par le relief.'
d['fire_blocked_cover']='Ligne de tir bloquée par un bois ou un bâtiment.'
d['fire_blocked_friendly']='Troupes amies dans la ligne de tir.'
d['formation_line_description']='Feu et contact : pleine efficacité. Déplacement normal.'
d['formation_column_description']='Mobilité : déplacement moins coûteux. Tir et contact réduits ; plus exposée aux tirs.'
d['formation_skirmish_description']='Protection contre les tirs. Feu légèrement réduit ; plus fragile au contact.'
for k in ['help_support','help_support_legacy']:
 d[k]=d[k].replace('Repos termine les actions de cette unité. ','').replace('La récupération est aussi automatique si vous laissez une unité au repos sans utiliser le bouton. ','')
d['help_support']=d['help_support'].replace('Sans tir volontaire ni assaut lancé pendant le cycle et hors déroute, une unité récupère un palier au début de son prochain tour si la liaison reste assurée.','RÉAPPROVISIONNEMENT AUTOMATIQUE : ravitaillement assuré + aucun tir volontaire ni assaut pendant votre tour = un niveau de munitions récupéré au début du prochain tour, hors déroute. Vous pouvez vous déplacer ; aucun bouton ni coût en PA supplémentaire.')
# Keep legacy help honest; automatic recovery still uses each save's own rules.
d['help_support_legacy']=d['help_support_legacy'].replace('Un cycle complet','Récupération automatique : un cycle complet')
for k in ['rest','rest_done']:d.pop(k,None)
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
for name in ['project.godot','export_presets.cfg']:
 p=root/name;s=p.read_text().replace('0.8.16','0.8.17').replace('version/code=29','version/code=30');p.write_text(s)
