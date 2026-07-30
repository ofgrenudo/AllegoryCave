extends Node2D


func _ready() -> void:
	print("ALERT: LOADED START MENU")
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	print("ACTION: User Pressed Start Button")
	pass


func _on_settings_button_pressed() -> void:
	print("ACTION: User Pressed Settings Button")
	pass


func _on_credits_button_pressed() -> void:
	print("ACTION: User Pressed Credits Button")
	pass


func _on_quit_button_pressed() -> void:
	print("ACTION: User Pressed Quit Start Button")
	pass
