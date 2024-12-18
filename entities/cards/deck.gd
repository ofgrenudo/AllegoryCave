class_name Deck extends Control


@export var selected = false
@export var scale_factor: float = 0.08;
@export var hover_scale_factor: float = 0.02;

@onready var image = get_node("Image")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Helper Functions
func get_selected():
	return selected

func set_selected(on_or_off: bool):
	selected = on_or_off

## Signals
func _on_image_mouse_entered() -> void:
	image.scale += Vector2(hover_scale_factor, hover_scale_factor)

func _on_image_mouse_exited() -> void:
	image.scale -= Vector2(hover_scale_factor, hover_scale_factor)
