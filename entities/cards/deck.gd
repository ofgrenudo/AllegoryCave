class_name Deck extends Control

enum DeckArt {
	DECK,
	END_TURN,
}

@export var art: DeckArt = DeckArt.DECK 

@export var selected = false
@export var scale_factor: float = 0.08;
@export var hover_scale_factor: float = 0.02;

@onready var image = get_node("Image")
@onready var loaded_image = load("res://entities/cards/deck_of_cards.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_image_art()

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
	
func load_image_art() -> void:
	match art:
		DeckArt.DECK:
			loaded_image = load("res://entities/cards/deck_of_cards.png")
		DeckArt.END_TURN:
			loaded_image = load("res://entities/cards/end_turn_deck_of_cards.png")
	
	image.texture = loaded_image
