extends Control

## Escape scene — the player made it out! Shown when
## Global.rooms_visited reaches Global.ROOMS_TO_ESCAPE.

func _ready() -> void:
	Global.reset_run()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select") or event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")
