extends Node2D

## Reward room! After a combat encounter (or at random) the player may land
## here to get either a heal or a card unlock.

@onready var title_label: Label = $UI/Panel/VBox/Title
@onready var desc_label: Label = $UI/Panel/VBox/Description
@onready var continue_button: Button = $UI/Panel/VBox/Continue

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	roll_reward()
	continue_button.pressed.connect(_on_continue_pressed)

func roll_reward() -> void:
	# Try to give the player a locked card first; if all owned, heal instead.
	var locked: Array = []
	for card_name in Global.card_states.keys():
		if not Global.card_states[card_name]:
			locked.append(card_name)

	if locked.size() > 0 and rng.randf() < 0.6:
		var pick: String = locked[rng.randi_range(0, locked.size() - 1)]
		Global.card_states[pick] = true
		title_label.text = "A new card!"
		desc_label.text = "You found: %s\nIt has been added to your collection." % pick
	else:
		var heal := 25
		Global.player_health = min(
			Global.PLAYER_MAX_HEALTH,
			Global.player_health + heal
		)
		title_label.text = "A moment of rest"
		desc_label.text = "You recovered %d health.\nCurrent health: %d / %d" % [
			heal, Global.player_health, Global.PLAYER_MAX_HEALTH
		]

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Navigation/Navigation.tscn")
