extends RefCounted
# Test harness only: refuse a mismatched report/save instead of silently mixing runs.
static func state_hash(state: Dictionary) -> String:
	return JSON.stringify(JSON.parse_string(JSON.stringify(state))).sha256_text()
static func problem(e,report,mode: String) -> String:
	if not report is Dictionary:return "report is not an object"
	for key in ["actions","decision_ms","counts","completed_turns","checks","failures","difficulty"]:
		if not report.has(key):return "missing "+key
	if report.difficulty!=mode or e.state.ai_difficulty!=mode:return "difficulty mismatch"
	if int(report.failures)!=0:return "previous failures"
	if not report.actions is Array or not report.decision_ms is Array:return "invalid action/timing arrays"
	if report.actions.size()!=report.decision_ms.size():return "action/timing mismatch"
	if not report.counts is Array or report.counts.size()!=2:return "invalid counters"
	var counts=[{},{}];var completed=0
	for action in report.actions:
		if not action is Dictionary or not action.get("decision") is Dictionary:return "invalid action"
		var side=int(action.get("side",-1));var kind=str(action.decision.get("kind",""))
		if side<0 or side>1 or kind.is_empty():return "invalid command"
		counts[side][kind]=int(counts[side].get(kind,0))+1
		if side==1 and kind=="end":completed+=1
	for side in [0,1]:
		if not report.counts[side] is Dictionary or counts[side].size()!=report.counts[side].size():return "action counters mismatch"
		for kind in counts[side]:
			if float(counts[side][kind])!=float(report.counts[side].get(kind,-1)):return "action counters mismatch"
	if completed!=int(report.completed_turns) or completed!=e.state.get("loss_history",[]).size():return "completed turns mismatch"
	if report.has("checkpoint_state_sha256"):
		if report.checkpoint_state_sha256!=state_hash(e.state):return "state fingerprint mismatch"
		if not report.get("ai_relocation") is Dictionary:return "missing AI continuation"
	else:
		# Legacy runs did not persist the artillery relocation plan. Only a phase
		# boundary is safe to resume with an empty plan.
		if report.actions.is_empty() or report.actions[-1].decision.kind!="end":return "legacy checkpoint is not a phase boundary"
		var last=report.actions[-1]
		var expected_turn=int(last.turn)+(1 if int(last.side)==1 and not e.state.finished else 0)
		var expected_side=1-int(last.side) if not e.state.finished else int(last.side)
		if int(e.state.turn)!=expected_turn or int(e.state.side)!=expected_side:return "legacy phase mismatch"
		if not report.get("boundaries") is Array or report.boundaries.is_empty():return "missing boundary evidence"
		var boundary=report.boundaries[-1]
		if int(boundary.actions)!=report.actions.size():return "legacy boundary mismatch"
		for side in [0,1]:
			if int(boundary.losses[side])!=e.losses(side) or int(boundary.prisoners[side])!=e.prisoners(side):return "legacy boundary mismatch"
	return ""
