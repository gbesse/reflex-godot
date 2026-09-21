# Purpose: Define finite market actions, reject stale decisions, and verify deterministic replay.
extends RefCounted
class_name ReflexRuntime

var state: Dictionary
var journal: Array[Dictionary] = []
var initial: Dictionary

func _init() -> void:
	reset()

func reset() -> void:
	state = {"revision": 0, "actors": [
		{"id": "ada", "name": "Ada", "stamina": 4, "stock": 3, "coins": 4},
		{"id": "bo", "name": "Bo", "stamina": 8, "stock": 1, "coins": 8},
		{"id": "cy", "name": "Cy", "stamina": 2, "stock": 2, "coins": 6}]}
	initial = state.duplicate(true)
	journal.clear()

func _actor(id: String) -> Dictionary:
	for actor: Dictionary in state.actors:
		if actor.id == id:
			return actor
	return {}

func actions(actor_id: String) -> Array[Dictionary]:
	var actor: Dictionary = _actor(actor_id)
	var result: Array[Dictionary] = []
	if actor.is_empty():
		return result
	result.append({"id": "wait", "description": "Wait without changing resources."})
	if actor.stamina < 10:
		result.append({"id": "rest", "description": "Recover three stamina, capped at ten."})
	for target: Dictionary in state.actors:
		if target.id == actor_id:
			continue
		if actor.stamina >= 1:
			result.append({"id": "greet:" + target.id, "description": "Greet " + target.name + "; spend one stamina."})
		if actor.stock > 0 and actor.stamina >= 2 and target.coins >= 2:
			result.append({"id": "sell:" + target.id, "description": "Sell one item to " + target.name + " for two coins; spend two stamina."})
	return result

func scripted(actor_id: String) -> String:
	var actor: Dictionary = _actor(actor_id)
	if actor.is_empty():
		return ""
	if actor.stamina < 3:
		return "rest"
	for action: Dictionary in actions(actor_id):
		if action.id.begins_with("sell:"):
			return action.id
	return "wait"

func apply(actor_id: String, action_id: String, expected_revision: int, source: String = "scripted") -> Dictionary:
	# Every effect is guarded again at commit time, even if the model selected a previously valid action.
	if expected_revision != state.revision:
		return {"ok": false, "error": "stale_revision"}
	var allowed: bool = false
	for candidate: Dictionary in actions(actor_id):
		if candidate.id == action_id:
			allowed = true
	if not allowed:
		return {"ok": false, "error": "invalid_action"}
	var actor: Dictionary = _actor(actor_id)
	if action_id == "rest":
		actor.stamina = mini(actor.stamina + 3, 10)
	elif action_id.begins_with("greet:"):
		actor.stamina -= 1
	elif action_id.begins_with("sell:"):
		var target: Dictionary = _actor(action_id.get_slice(":", 1))
		actor.stamina -= 2
		actor.stock -= 1
		actor.coins += 2
		target.stock += 1
		target.coins -= 2
	state.revision += 1
	var entry: Dictionary = {"actor": actor_id, "action": action_id, "revision": expected_revision, "source": source, "after": state.duplicate(true)}
	journal.append(entry)
	return {"ok": true, "entry": entry.duplicate(true)}

static func verify_replay(entries: Array[Dictionary]) -> Dictionary:
	var runtime := ReflexRuntime.new()
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		if not entry.has_all(["actor", "action", "revision", "after", "source"]):
			return {"ok": false, "index": index, "error": "invalid_entry"}
		var result: Dictionary = runtime.apply(entry.actor, entry.action, entry.revision, entry.source)
		if not result.ok or runtime.state != entry.after:
			return {"ok": false, "index": index, "error": "trace_diverged"}
	return {"ok": true, "events": entries.size(), "state": runtime.state.duplicate(true)}
