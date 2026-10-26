extends "res://tests/test_ai_compat0833.gd"
func _initialize():
 var args=OS.get_cmdline_user_args();var report=JSON.parse_string(FileAccess.get_file_as_string(args[0]));var e=Rules.new(JSON.parse_string(FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json")))
 e.new_game(0,"hard");e.state.seed=int(report.seed);e.state.ai_style=int(report.style)
 var w=e.index(Vector2i(13,10));var rows=[];var previous="";var shots=[];var crossings=[]
 for a in report.actions:
  var before=e.unit_at(w);var d=a.decision
  if d.kind in ["fire","assault"] and before>=0 and str(d.target)==str(e.state.units[before].id):shots.append({"turn":a.turn,"side":a.side,"kind":d.kind,"attacker":d.unit,"defender":d.target,"strength_before":e.state.units[before].strength})
  check(int(e.state.turn)==int(a.turn) and int(e.state.side)==int(a.side),"same phase")
  check(dispatch(e,d) and e.validate(e.state),"replay legal")
  if int(a.side)==1 and d.kind=="move" and d.path.any(func(v):return int(v)==w):
   var mover=e.unit_index(str(d.unit));var endpoint=e.unit_cell(e.state.units[mover]);var numeric_path=[]
   for cell in d.path:numeric_path.append(int(cell))
   var wi=numeric_path.find(w);var ei=numeric_path.find(endpoint)
   if wi>0 and ei>=wi:crossings.append({"turn":a.turn,"unit":d.unit,"path":d.path,"actual_endpoint":endpoint,"garrison_before":before,"endpoint_is_woerth":endpoint==w})
  var n=e.unit_at(w);var id=str(e.state.units[n].id) if n>=0 else "empty"
  if id!=previous:
   rows.append({"turn":a.turn,"side_phase":a.side,"occupant":id,"occupant_side":int(e.state.units[n].side) if n>=0 else -1,"trigger":d});previous=id
 var expected=JSON.parse_string(FileAccess.get_file_as_string(args[0]+".state.json"));var copy=Rules.new(e.pack);copy.state=expected
 var actual=FileAccess.open(args[1]+".actual.json",FileAccess.WRITE);actual.store_string(JSON.stringify(e.state));actual.close()
 check(JSON.parse_string(JSON.stringify(e.state))==expected,"replayed complete state matches checkpoint")
 var f=FileAccess.open(args[1],FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"transitions":rows,"attacks_on_garrison":shots,"prussian_crossings":crossings},"\t"));f.close();print("REPLAY ",checks-failures,"/",checks);quit(1 if failures else 0)
