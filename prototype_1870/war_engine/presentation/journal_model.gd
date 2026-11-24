extends RefCounted
## Builds display records from existing saves. No invented dates or hidden names.
static func stamp(e,turn: int,ending: bool=false) -> String:
	if turn<1:return "Date non consignée"
	var minutes=(turn-(0 if ending else 1))*int(e.pack.rules.minutes)
	return ("Fin T%d · %02d:%02d" if ending else "T%d · %02d:%02d")%[turn,int(e.pack.rules.start_hour)+minutes/60,minutes%60]

static func row(category: String,title: String,body: String,turn: int=-1) -> Dictionary:
	return {"category":category,"title":title,"body":body,"turn":turn}

static func surrenders(g) -> Array:
	var e=g.engine;var side=int(e.state.human_side);var found={};var records=[];var rows=[]
	for event in e.state.get("support_events",[]):
		if event.kind=="surrender":records.append(event)
	for event in e.state.get("battle_history",[]):
		if event.kind=="surrender":records.append(event)
	for event in records:
		var id=str(event.unit)
		if found.has(id):continue
		var n=e.unit_index(id)
		if n<0:continue
		var name=""
		if int(event.side)==side or not e.fog_enabled() or e.state.finished:name=str(e.state.units[n].name_key)
		elif event.get("known_names",{}) is Dictionary:name=str(event.get("known_names",{}).get(str(side),""))
		if name.is_empty():
			for combat in e.state.events:
				if int(combat.turn)!=int(event.turn):continue
				var slot=1 if int(combat.target)==n and int(combat.prisoners)>0 else 0 if int(combat.shooter)==n and int(combat.attacker_prisoners)>0 else -1
				if slot>=0:name=str(combat.get("fog_names",{}).get(str(side),["fog_enemy_generic","fog_enemy_generic"])[slot]);break
		if name.is_empty():continue
		found[id]=true
		rows.append(row("surrender","Reddition","Tour %d — %s : %s se rend (%d prisonniers)."%[int(event.turn),g.camp(int(event.side)),g.t(name),int(event.prisoners)],int(event.turn)))
	return rows

static func build(g) -> Dictionary:
	var e=g.engine;var own=int(e.state.human_side);var exact=not e.fog_enabled() or e.state.finished
	var goals=[]
	for goal in e.objective_definitions():goals.append(g.t(goal.get("name_key","objective"))+" : "+str(int(goal.points))+(" point" if int(goal.points)==1 else " points"))
	var victory=e.pack.rules.get("victory",{})
	var summary=" · ".join(goals)+". Score : %d/%d/%d."%[int(victory.get("final_control",60)),int(victory.get("duration",20)),int(victory.get("military",20))]
	var losses=[]
	for side in [0,1]:losses.append(g.camp(side)+" "+(str(e.losses(side)) if exact or side==own else "?"))
	var rows=[row("all","Bilan du tour","Pertes cumulées : "+" | ".join(losses)+( "" if exact else " (pertes adverses non confirmées)"),int(e.state.turn))]
	for k in range(e.state.events.size()-1,-1,-1):
		var event=e.state.events[k];var names=[e.state.units[int(event.shooter)].name_key,e.state.units[int(event.target)].name_key]
		if not exact:names=event.get("fog_names",{}).get(str(own),["fog_enemy_generic","fog_enemy_generic"])
		var body=g.t("journal_combat")%[event.turn,g.t(names[0]),g.t(names[1]),g.t("kind_"+event.kind)]
		body+="\n"+g.combat_summary(event)+"\n"+g.t("journal_reaction" if event.reaction else "journal_no_reaction")
		if exact:
			if int(event.prisoners)>0:body+=" • "+g.t("combat_prisoners")%[g.camp(1-int(event.side)),event.prisoners]
			if int(event.attacker_prisoners)>0:body+=" • "+g.t("combat_prisoners")%[g.camp(int(event.side)),event.attacker_prisoners]
		if not event.retreat.is_empty() or not event.attacker_retreat.is_empty():body+=" • "+g.t("retreat")
		rows.append(row("combat","Combat · "+g.t("kind_"+event.kind),body,int(event.turn)))
	rows.append_array(surrenders(g))
	for event in e.state.get("battle_history",[]):
		if event.kind!="capture":continue
		for goal in e.objective_definitions():
			if str(goal.id)==str(event.objective):rows.append(row("objective","Objectif capturé",g.t(goal.get("name_key","objective"))+" passe sous contrôle "+("français." if int(event.side)==0 else "prussien."),int(event.turn)))
	for event in e.state.get("support_events",[]):
		if event.kind=="surrender" or int(event.side)!=own:continue
		rows.append(row("all","Liaisons",g.t("support_cut_notice")%g.t(event.name_key)+"\n"+g.link_journal_detail(event),int(event.turn)))
	for n in range(e.state.units.size()):
		var u=e.state.units[n]
		if int(u.side)!=own or int(u.get("arrival_turn",1))<=1:continue
		var name=g.t(str(u.name_key)+"_short") if g.texts.has(str(u.name_key)+"_short") else g.t(u.name_key)
		var due=e.reinforcement_turn(u)
		if not u.has("pending"):
			rows.append(row("reinforcement","Renfort · situation ancienne",name+"\nArrivée non consignée dans cette sauvegarde."));continue
		if u.pending:
			var late=due<int(e.state.turn) or (due==int(e.state.turn) and int(e.state.side)>=int(u.side))
			var entry=row("reinforcement","Renfort · "+("arrivée reportée" if late else "prévu"),name+"\n"+("Entrée indisponible lors du dernier contrôle. " if late else "")+"Arrivée prévue "+stamp(e,due)+".")
			if late and e.headquarters(n):entry.priority=1
			if e.headquarters(n):entry.body=g.t("hq_arrival_delayed" if late else "hq_arrival_scheduled")%[g.t(u.name_key),due,int(u.cell[0]),int(u.cell[1])]
			entry.stamp="Prévu "+stamp(e,due);rows.append(entry)
		else:rows.append(row("reinforcement","Renfort arrivé",name+"\nArrivée confirmée · date effective non consignée."))
	var history=e.state.get("loss_history",[])
	if history.is_empty():rows.append(row("all","Historique des pertes","Aucun tour enregistré. Les anciennes sauvegardes ne permettent pas de reconstituer les tours passés."))
	elif int(history[0].turn)>1:rows.append(row("all","Historique incomplet","Les tours antérieurs au premier relevé n’ont pas été enregistrés dans cette sauvegarde."))
	for snapshot in history:
		var lines=[]
		for side in [0,1]:
			lines.append(g.camp(side)+" : "+(str(snapshot.losses[side]) if exact or own==side else "?")+" pertes, "+(str(snapshot.prisoners[side]) if exact or own==side else "?")+" prisonniers")
		var snapshot_row=row("all","Fin du tour %d · bilan"%int(snapshot.turn),"\n".join(lines),int(snapshot.turn));snapshot_row.stamp=stamp(e,int(snapshot.turn),true);rows.append(snapshot_row)
	# Order by recorded turn only. Cross-system within-turn timing was not saved.
	for k in range(rows.size()):rows[k].order=k
	rows.sort_custom(func(a,b):
		if int(a.get("priority",0))!=int(b.get("priority",0)):return int(a.get("priority",0))>int(b.get("priority",0))
		return int(a.turn)>int(b.turn) if int(a.turn)!=int(b.turn) else int(a.order)<int(b.order))
	return {"summary":summary,"rows":rows}

static func filtered(rows: Array,category: String) -> Array:
	var result=[]
	for item in rows:
		if category=="all" or item.category==category:result.append(item)
	return result
