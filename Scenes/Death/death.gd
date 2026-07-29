extends Control

## Death screen — shows the "you died" image and returns to the Main Menu
## on click or key press. Resets the run state so the next attempt starts fresh.

func _ready() -> void:
	# Make sure the next run starts clean.
	Global.reset_run()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select") or event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")
