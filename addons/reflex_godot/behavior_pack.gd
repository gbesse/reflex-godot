# Purpose: Store reusable NPC decision instructions as an editable Godot Resource.
@tool
extends Resource
class_name ReflexBehaviorPack

@export_multiline var instructions: String = "Keep the market active. Recover stamina when tired, trade when possible, otherwise greet another actor."
@export_range(0.0, 1.0) var minimum_probability: float = 0.65
@export var model: String = "jev-1.13.0"
