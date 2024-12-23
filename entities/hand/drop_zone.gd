extends TextureRect

func handle_card_drop(card):
	# Logic for when a card is dropped on the DropZone
	print("Card ", card.CardType.keys()[card.type], " ", card.CardArt.keys()[card.type], " was dropped on DropZone")
	# Add your logic for processing the dropped card
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
