extends Node2D

@export var card_type = "Normal"
@export var card_damage = 15
@export var selected = false

func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Signal Handlers
func _on_area_2d_mouse_entered() -> void:
	scale += Vector2(0.05, 0.05)

func _on_area_2d_mouse_exited() -> void:
	scale -= Vector2(0.05, 0.05)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		selected = true
