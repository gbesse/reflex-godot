# Purpose: Let users step finite NPC actions, inspect resources, and verify the recorded replay.
extends Control

var runtime := ReflexRuntime.new()
var adapter: ReflexJevAdapter
var behavior := ReflexBehaviorPack.new()
var mode: CheckButton
var status: Label
var actors: Label
var log_view: RichTextLabel
var step_button: Button
var reset_button: Button
var cursor: int = 0
var pending_actor: String = ""

func _ready() -> void:
	adapter = ReflexJevAdapter.new()
	add_child(adapter)
	adapter.decision_ready.connect(_decision)
	adapter.decision_failed.connect(_failed)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 28)
	add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)
	var title := Label.new()
	title.text = "REFLEX  /  The little market"
	title.add_theme_font_size_override("font_size", 30)
	box.add_child(title)
	actors = Label.new()
	actors.add_theme_font_size_override("font_size", 20)
	box.add_child(actors)
	var controls := HBoxContainer.new()
	box.add_child(controls)
	step_button = Button.new()
	step_button.text = "Next action"
	step_button.pressed.connect(_step)
	controls.add_child(step_button)
	var replay_button := Button.new()
	replay_button.text = "Verify replay"
	replay_button.pressed.connect(func() -> void: status.text = JSON.stringify(ReflexRuntime.verify_replay(runtime.journal)))
	controls.add_child(replay_button)
	reset_button = Button.new()
	reset_button.text = "Reset"
	reset_button.pressed.connect(func() -> void: runtime.reset(); cursor = 0; log_view.clear(); _refresh())
	controls.add_child(reset_button)
	mode = CheckButton.new()
	mode.text = "Use Jev"
	mode.disabled = OS.get_environment("TYPESAFE_API_KEY").is_empty()
	mode.tooltip_text = "Development only: start Godot with TYPESAFE_API_KEY. Never ship a provider key in a game."
	controls.add_child(mode)
	status = Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.text = "Scripted decisions. Resources are guarded before each action."
	box.add_child(status)
	log_view = RichTextLabel.new()
	log_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(log_view)
	_refresh()

func _refresh() -> void:
	actors.text = "Turn %d\n" % runtime.state.revision
	for actor: Dictionary in runtime.state.actors:
		actors.text += "%s    stamina %d    stock %d    coins %d\n" % [actor.name, actor.stamina, actor.stock, actor.coins]

func _step() -> void:
	pending_actor = runtime.state.actors[cursor % 3].id
	cursor += 1
	if mode.button_pressed:
		step_button.disabled = true
		reset_button.disabled = true
		status.text = "Waiting for Jev…"
		adapter.choose(runtime.state.duplicate(true), pending_actor, runtime.actions(pending_actor), behavior)
	else:
		_commit(runtime.scripted(pending_actor), runtime.state.revision, "scripted")

func _decision(action: String, revision: int, probability: float) -> void:
	step_button.disabled = false
	reset_button.disabled = false
	_commit(action, revision, "jev %.3f" % probability)

func _commit(action: String, revision: int, source: String) -> void:
	var result: Dictionary = runtime.apply(pending_actor, action, revision, source)
	if not result.ok:
		_failed(result.error)
		return
	status.text = "%s → %s (%s)" % [pending_actor, action, source]
	log_view.add_text(status.text + "\n")
	_refresh()

func _failed(message: String) -> void:
	step_button.disabled = false
	reset_button.disabled = false
	status.text = "Decision failed: " + message
	push_error(message)
