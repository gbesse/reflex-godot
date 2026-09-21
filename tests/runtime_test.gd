# Purpose: Exercise guarded effects, conservation, replay tampering and Jev response rejection in the engine.
extends SceneTree

const Runtime = preload("res://addons/reflex_godot/reflex_runtime.gd")
const Adapter = preload("res://addons/reflex_godot/jev_adapter.gd")
const EditorAddon = preload("res://addons/reflex_godot/editor_plugin.gd")
const Playground = preload("res://demo/playground.gd")
var checks: int = 0
var failures: int = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var runtime := Runtime.new()
	var before: Dictionary = runtime.state.duplicate(true)
	check(not runtime.apply("ada", "sell:bo", -1).ok, "stale revision accepted")
	check(not runtime.apply("ada", "invented", 0).ok, "unknown action accepted")
	check(runtime.state == before, "rejected action mutated state")
	for i in range(100):
		var actor: String = runtime.state.actors[i % 3].id
		check(runtime.apply(actor, runtime.scripted(actor), runtime.state.revision).ok, "valid action rejected")
		var coins: int = 0
		var stock: int = 0
		for row: Dictionary in runtime.state.actors:
			check(row.stamina >= 0 and row.stamina <= 10 and row.stock >= 0 and row.coins >= 0, "negative resource")
			coins += row.coins
			stock += row.stock
		check(coins == 18 and stock == 6, "trade failed conservation")
	check(Runtime.verify_replay(runtime.journal).ok, "valid replay failed")
	var altered: Array[Dictionary] = runtime.journal.duplicate(true)
	altered[0].after.actors[0].coins = 999
	check(not Runtime.verify_replay(altered).ok, "tampered replay accepted")
	var available: Array[Dictionary] = [{"id": "wait"}, {"id": "rest"}]
	var payload: Dictionary = {"model": "jev-1.13.0", "answers": {"action": {"type": "choice", "choice": "action1", "confidence": 0.9, "probabilities": {"action0": 0.1, "action1": 0.9}}}}
	var parsed: Dictionary = Adapter.parse_decision(payload, available, "jev-1.13.0", 0.65)
	check(parsed.ok and parsed.action == "rest", "valid Jev reply rejected")
	check(not Adapter.parse_decision(payload, available, "different", 0.65).ok, "model mismatch accepted")
	check(not Adapter.parse_decision(payload, available, "jev-1.13.0", 0.95).ok, "weak choice accepted")
	payload.answers.action.probabilities.action1 = 1.5
	check(not Adapter.parse_decision(payload, available, "jev-1.13.0", 0.65).ok, "invalid probability accepted")
	check(not Adapter.parse_decision(null, available, "jev-1.13.0", 0.65).ok, "invalid JSON accepted")
	print("Reflex: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
