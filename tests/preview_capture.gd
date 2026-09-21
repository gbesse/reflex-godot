# Purpose: Render the scripted playground to docs/playground.png for visual inspection; requires a display.
extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene: Control = load("res://demo/playground.tscn").instantiate()
	root.add_child(scene)
	for i in range(6):
		scene._step()
	await process_frame
	await RenderingServer.frame_post_draw
	var error: Error = root.get_texture().get_image().save_png("res://docs/playground.png")
	if error != OK:
		push_error("Could not save playground preview: %d" % error)
	quit(0 if error == OK else 1)
