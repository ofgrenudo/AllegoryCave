extends TextureRect

@onready var card_dropped = false
@onready var card_dropped_type = null
@onready var card_dropped_damage = null

func handle_card_drop(card):
	# Logic for when a card is dropped on the DropZone
	print("DROPZONE > Card Type: ", card.type, " Damage: ", card.damage, " was dropped on DropZone")

	# Add your logic for processing the dropped card
	card_dropped_type = card.type
	card_dropped_damage = card.damage
	card_dropped = true

func get_card_dropped():
	return [card_dropped_type, card_dropped_damage]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
