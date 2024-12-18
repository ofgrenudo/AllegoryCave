class_name Card extends Control

## CardTypes
## Each card must have a type, with normal being the most common.
enum CardType {
	NORMAL,
	FIRE,
	ICE,
	ACID,
	LIGHT,
	LIGHTNING,
}

## CardArt
## Each Card art has a specific file path. Right now this is kind of a long list, but once we get 
## all the cards made, we can probabl expand to only doing king through ace, and let the card type
## determine the actual type of card. Theres also a way we can probably do this programatically. 
## I should talk to @antisocialdinos about this one....
enum CardArt {
	## NORMAL
	BLANK_CARD,
	CLUB_ACE,
	CLUB_EIGHT,
	DIAMOND_ACE,
	DIAMOND_FIVE,
	DIAMOND_QUEEN,
	DIAMOND_SEVEN,
	HEART_ACE,
	HEART_DIAMOND,
	HEART_THREE,
	SPADE_QUEEN,
	SPADE_TWO,
	## MAGIC
	ACID_CLOVER_EIGHT,
	ACID_DIAMOND_FIVE,
	FIRE_SPADE_TWO,
	ICE_HEART_THREE,
	ICE_SPADE_TWO,
	LIGHT_CLOVER_ACE,
	LIGHT_CLOVER_QUEEN,
	LIGHT_DIAMOND_ACE,
	LIGHT_DIAMOND_FIVE,
	LIGHTNING_DIAMOND_ACE,
	LIGHTNING_DIAMOND_SEVEN,
}

var loaded_art

## These are the variables that will go into the Inspector
@export var selected_art: CardArt = CardArt.BLANK_CARD
@export var type: CardType = CardType.NORMAL
@export var damage: int = 15
@export var selected = false
@export var scale_factor: float = 0.08;
@export var hover_scale_factor: float = 0.02;

@onready var image = get_node("Image")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_selected_texture()
	image.scale = Vector2(scale_factor, scale_factor)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Helper Functions
func get_type():
	return type

func get_damage():
	return damage

func get_selected():
	return selected

func set_selected(on_or_off: bool):
	selected = on_or_off

## Apply our loaded texture to the TextureRect.texture value
func load_selected_texture():
	print("CARD > Loading Card Texture ", selected_art)
	match selected_art:
		CardArt.BLANK_CARD:
			loaded_art = preload("res://entities/cards/blank_card.png")
		CardArt.CLUB_ACE:
			loaded_art = preload("res://entities/cards/normal/club_ace.png")
		CardArt.CLUB_EIGHT:
			loaded_art = load("res://entities/cards/normal/club_eight.png")
		CardArt.DIAMOND_ACE:
			loaded_art = load("res://entities/cards/normal/diamond_ace.png")
		CardArt.DIAMOND_FIVE:
			loaded_art = load("res://entities/cards/normal/diamond_five.png")
		CardArt.DIAMOND_QUEEN:
			loaded_art = load("res://entities/cards/normal/diamond_queen.png")
		CardArt.DIAMOND_SEVEN:
			loaded_art = load("res://entities/cards/normal/diamond_seven.png")
		CardArt.HEART_ACE:
			loaded_art = load("res://entities/cards/normal/heart_ace.png")
		CardArt.HEART_DIAMOND:
			loaded_art = load("res://entities/cards/normal/heart_diamond.png")
		CardArt.HEART_THREE:
			loaded_art = load("res://entities/cards/normal/heart_three.png")
		CardArt.SPADE_QUEEN:
			loaded_art = load("res://entities/cards/normal/spade_queen.png")
		CardArt.SPADE_TWO:
			loaded_art = load("res://entities/cards/normal/spade_two.png")
		CardArt.ACID_CLOVER_EIGHT:
			loaded_art = load("res://entities/cards/magic/acid_clover_eight.png")
		CardArt.ACID_DIAMOND_FIVE:
			loaded_art = load("res://entities/cards/magic/acid_diamond_five.png")
		CardArt.FIRE_SPADE_TWO:
			loaded_art = load("res://entities/cards/magic/fire_spade_two.png")
		CardArt.ICE_HEART_THREE:
			loaded_art = load("res://entities/cards/magic/ice_heart_three.png")
		CardArt.ICE_SPADE_TWO:
			loaded_art = load("res://entities/cards/magic/ice_spade_two.png")
		CardArt.LIGHT_CLOVER_ACE:
			loaded_art = load("res://entities/cards/magic/light_clover_ace.png")
		CardArt.LIGHT_CLOVER_QUEEN:
			loaded_art = load("res://entities/cards/magic/light_clover_ace.png")
		CardArt.LIGHT_DIAMOND_ACE:
			loaded_art = load("res://entities/cards/magic/light_diamond_ace.png")
		CardArt.LIGHT_DIAMOND_FIVE:
			loaded_art = load("res://entities/cards/magic/light_diamond_five.png")
		CardArt.LIGHTNING_DIAMOND_ACE:
			loaded_art = load("res://entities/cards/magic/lightning_diamond_ace.png")
		CardArt.LIGHTNING_DIAMOND_SEVEN:
			loaded_art = load("res://entities/cards/magic/lightning_diamond_seven.png")
		_:
			loaded_art = load("res://entities/cards/blank_card.png")

	image.texture = loaded_art

## Signals
func _on_mouse_entered() -> void:
	image.scale += Vector2(hover_scale_factor, hover_scale_factor)

func _on_mouse_exited() -> void:
	image.scale -= Vector2(hover_scale_factor, hover_scale_factor)
	
