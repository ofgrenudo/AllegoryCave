extends Control

## Deck Manager — shows every card in the player's inventory (Global.card_owned)
## and lets them toggle which of those are active in their deck
## (Global.card_states), bounded by MIN/MAX_DECK_SIZE. Cards not yet owned
## (e.g. an elemental card not yet taught by an NPC) simply don't appear.

@onready var card_grid: GridContainer = $CardGrid

const CARD_SIZE := Vector2(140, 190)

var selected_cards_count := 0
var card_materials: Dictionary = {}   # card_name -> ShaderMaterial (b/w)

func _ready() -> void:
	_build_inventory_grid()

# Reusable Functions
func _build_inventory_grid() -> void:
	var bw_shader := load("res://Scenes/Deck Manager/deck_manager.gdshader")

	for card_name in Global.card_owned.keys():
		if not Global.card_owned[card_name] or not Global.CARD_TEXTURES.has(card_name):
			continue

		var rect := TextureRect.new()
		rect.name = card_name
		rect.texture = load(Global.CARD_TEXTURES[card_name])
		rect.custom_minimum_size = CARD_SIZE
		rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.mouse_filter = Control.MOUSE_FILTER_STOP

		var bw_material := ShaderMaterial.new()
		bw_material.shader = bw_shader
		card_materials[card_name] = bw_material

		rect.mouse_entered.connect(_on_card_mouse_entered.bind(rect))
		rect.mouse_exited.connect(_on_card_mouse_exited.bind(rect))
		rect.gui_input.connect(_on_card_gui_input.bind(rect, card_name))

		card_grid.add_child(rect)

		if Global.card_states[card_name]:
			selected_cards_count += 1
			rect.material = null
		else:
			rect.material = bw_material

func _on_card_mouse_entered(card: TextureRect) -> void:
	if not Global.card_states[card.name]:
		card.material = null
		card.scale += Vector2(0.05, 0.05)

func _on_card_mouse_exited(card: TextureRect) -> void:
	if not Global.card_states[card.name]:
		card.material = card_materials[card.name]
	card.scale -= Vector2(0.05, 0.05)

func _on_card_gui_input(event: InputEvent, card: TextureRect, card_name: String) -> void:
	if not event.is_action_pressed("select"):
		return

	if not Global.card_states[card_name] and selected_cards_count < Global.MAX_DECK_SIZE:
		# Select the card
		Global.card_states[card_name] = true
		card.material = null
		selected_cards_count += 1
		print("Selected: ", card_name, " - Total Selected: ", selected_cards_count)
	elif Global.card_states[card_name] and selected_cards_count > Global.MIN_DECK_SIZE:
		# Deselect the card (only if we'd stay at/above MIN)
		Global.card_states[card_name] = false
		card.material = card_materials[card_name]
		selected_cards_count -= 1
		print("Deselected: ", card_name, " - Total Selected: ", selected_cards_count)
	elif Global.card_states[card_name]:
		print("Cannot deselect: deck at minimum size (", Global.MIN_DECK_SIZE, ")")
