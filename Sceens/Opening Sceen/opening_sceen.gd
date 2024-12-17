extends Node2D

@onready var navigation = preload("res://Sceens/Navigation/Navigation.tscn")
@onready var cards = get_node("Room/Cards")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		get_tree().change_scene_to_packed(navigation)

func _on_area_2d_mouse_entered() -> void:
	cards.scale += Vector2(0.05, 0.05)


func _on_area_2d_mouse_exited() -> void:
	cards.scale -= Vector2(0.05, 0.05)
