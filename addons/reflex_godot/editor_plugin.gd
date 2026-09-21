# Purpose: Add an editor dock that opens the runnable playground and creates inspectable behavior resources.
@tool
extends EditorPlugin

var _dock: EditorDock

func _enter_tree() -> void:
	_dock = EditorDock.new()
	_dock.title = "Reflex"
	_dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UL
	_dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_FLOATING
	var box := VBoxContainer.new()
	var open := Button.new()
	open.text = "Open playground"
	open.disabled = not ResourceLoader.exists("res://demo/playground.tscn")
	open.pressed.connect(func() -> void: EditorInterface.open_scene_from_path("res://demo/playground.tscn"))
	box.add_child(open)
	var create := Button.new()
	create.text = "Create behavior pack"
	create.pressed.connect(func() -> void: EditorInterface.edit_resource(ReflexBehaviorPack.new()))
	box.add_child(create)
	_dock.add_child(box)
	add_dock(_dock)

func _exit_tree() -> void:
	remove_dock(_dock)
	_dock.queue_free()
