extends RefCounted
# A final report only: exact opposing totals must not leak into an ongoing game.
static func decimal(value) -> String:return ("%.2f"%float(value)).replace(".",",")
static func build(e,texts: Dictionary) -> String:
 if not e.state.get("finished",false):return ""
 var tr=func(key):return str(texts.get(str(key),str(key)))
 var camps=[tr.call("france"),tr.call("germany")];var result=e.result_for(int(e.state.human_side))
 var lines=["RAPPORT DE BATAILLE — "+tr.call("result_"+result.level),"%d tours terminés · %s"%[e.battle_turn_limit(),tr.call("difficulty_"+str(e.state.ai_difficulty))],"","OBJECTIFS FINAUX"]
 for goal in e.objective_definitions():
  var owner=e.objective_owner(goal)
  lines.append("%s · %d %s : %s"%[tr.call(goal.get("name_key","objective")),int(goal.points),"point" if int(goal.points)==1 else "points",camps[owner] if owner in [0,1] else "Sans contrôle"])
 lines.append("\nBILAN DES FORCES — pertes hors prisonniers ; morts et blessés non distingués")
 for side in [0,1]:
  var surrendered={}
  for event in e.state.get("battle_history",[])+e.state.get("support_events",[]):
   if event.kind=="surrender" and int(event.side)==side:surrendered[str(event.unit)]=true
  lines.append("%s : %d hommes au départ ; %d restants.\nPertes : %d ; prisonniers : %d ; total militaire : %d (%s %%).\nUnités capitulées enregistrées : %d ; unités encore en déroute : %d."%[camps[side],e.initial_force(side),e.initial_force(side)-e.military_losses(side),e.losses(side),e.prisoners(side),e.military_losses(side),decimal(100.0*e.military_losses(side)/maxi(1,e.initial_force(side))),surrendered.size(),e.routed_count(side)])
 lines.append("\nCALCUL DU SCORE — 60 / 20 / 20")
 for side in [0,1]:
  var p=result.parts[side]
  lines.append("%s\nObjectifs : 60 × %d / %d = %s\nDurée : 20 × %d / %d = %s\nPertes infligées : 20 × %d / %d = %s\nTOTAL : %s"%[camps[side],e.controlled_value(side),int(e.objective_value_total()),decimal(p[0]),int(e.state.scores[side]),e.battle_turn_limit()*int(e.objective_value_total()),decimal(p[1]),e.military_losses(1-side),e.initial_force(1-side),decimal(p[2]),decimal(result.totals[side])])
 lines.append("\nACTIVITÉ DE COMBAT — actions principales, ripostes séparées")
 for side in [0,1]:
  var cannon=0;var other=0;var assaults=0;var charges=0;var replies=0
  for event in e.state.events:
   if int(event.side)==side:
    match event.kind:
     "fire":
      if event.get("cannon",false):cannon+=1
      else:other+=1
     "assault":assaults+=1
     "charge":charges+=1
   elif event.get("reaction",false):replies+=1
  lines.append("%s : %d tirs de canon ; %d autres tirs ; %d assauts ; %d charges ; %d ripostes."%[camps[side],cannon,other,assaults,charges,replies])
 lines.append("Mouvements des deux camps : %d. Les trajectoires passées ne sont pas conservées."%int(e.state.moves))
 lines.append("\nCAPTURES ET CAPITULATIONS")
 var seen={};var timeline=e.state.get("battle_history",[]).duplicate(true)
 for event in timeline:
  if event.kind=="surrender":seen[str(event.unit)]=true
 for event in e.state.get("support_events",[]):
  if event.kind=="surrender" and not seen.has(str(event.unit)):timeline.append(event);seen[str(event.unit)]=true
 timeline.sort_custom(func(a,b):return int(a.turn)<int(b.turn))
 if timeline.is_empty():lines.append(tr.call("battle_details_legacy"))
 if not e.state.has("battle_history"):lines.append("Historique ancien incomplet : aucune capture manquante n’est reconstituée.")
 for event in timeline:
  if event.kind=="capture":
   for goal in e.objective_definitions():
    if goal.id==event.objective:lines.append("T%d — %s pris par les %s."%[int(event.turn),tr.call(goal.get("name_key","objective")),camps[int(event.side)]])
  else:
   var n=e.unit_index(str(event.unit))
   if n>=0:lines.append("T%d — %s (%s) se rend : %d prisonniers."%[int(event.turn),tr.call(e.state.units[n].name_key),camps[int(event.side)],int(event.prisoners)])
 lines.append("\nÉVOLUTION DES PERTES — cumul hors prisonniers, puis prisonniers")
 if e.state.get("loss_history",[]).is_empty():lines.append("Historique non enregistré dans cette ancienne sauvegarde.")
 for row in e.state.get("loss_history",[]):lines.append("Fin T%d : France %d + %d prisonniers ; Prusse %d + %d prisonniers."%[int(row.turn),row.losses[0],row.prisoners[0],row.losses[1],row.prisoners[1]])
 return "\n".join(lines)
