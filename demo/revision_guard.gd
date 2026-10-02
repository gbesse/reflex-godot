# Purpose: Show that a once-valid action cannot commit against an old world revision.
extends SceneTree

const Runtime = preload("res://addons/reflex_godot/reflex_runtime.gd")

func _initialize() -> void:
	var runtime := Runtime.new()
	var original_revision: int = runtime.state.revision
	var first: Dictionary = runtime.apply("ada", "rest", original_revision)
	var stale: Dictionary = runtime.apply("ada", "sell:bo", original_revision)
	var passed: bool = first.ok and not stale.ok and stale.error == "stale_revision" and runtime.journal.size() == 1
	print(JSON.stringify({"source": "scripted fixture; no Jev call", "first_committed": first.ok, "stale_rejected": not stale.ok, "journal_events": runtime.journal.size()}))
	quit(0 if passed else 1)
