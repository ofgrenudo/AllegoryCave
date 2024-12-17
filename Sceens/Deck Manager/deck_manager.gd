extends Control

# Card Objects
@onready var lightning_one = get_node("PageOne/RowOne/LightningOne")
@onready var lightning_two = get_node("PageOne/RowOne/LightningTwo")
@onready var fire_one = get_node("PageOne/RowOne/FireOne")
@onready var ice_one = get_node("PageOne/RowOne/IceOne")
@onready var acid_one = get_node("PageOne/RowOne/AcidOne")
@onready var acid_two = get_node("PageOne/RowOne/AcidTwo")
@onready var light_one = get_node("PageOne/RowOne/LightOne")
@onready var light_two = get_node("PageOne/RowTwo/LightTwo")
@onready var ice_two = get_node("PageOne/RowTwo/IceTwo")
@onready var seven_diamond = get_node("PageOne/RowTwo/SevenDiamond")
@onready var three_hearts = get_node("PageOne/RowTwo/ThreeHearts")
@onready var eight_clubs = get_node("PageOne/RowTwo/EightClubs")
@onready var five_diamonds = get_node("PageOne/RowTwo/FiveDiamond")
@onready var ace_diamond = get_node("PageOne/RowTwo/AceDiamond")

# Selected Cards Counter
var selected_cards_count = 0
const MIN_SELECTION = 3
const MAX_SELECTION = 6

# Shader Material
@onready var bw_shader_material = ShaderMaterial.new()

func _ready() -> void:
	# Load and apply black-and-white shader to all cards initially
	var bw_shader = load("res://Sceens/Deck Manager/deck_manager.gdshader")
	bw_shader_material.shader = bw_shader
	
	initialize_cards()



# Reusable Functions
func initialize_cards():
	# Map of cards for easy access
	var cards = {
		"LightningOne": lightning_one,
		"LightningTwo": lightning_two,
		"FireOne": fire_one,
		"IceOne": ice_one,
		"AcidOne": acid_one,
		"AcidTwo": acid_two,
		"LightOne": light_one,
		"LightTwo": light_two,
		"IceTwo": ice_two,
		"SevenDiamond": seven_diamond,
		"ThreeHearts": three_hearts,
		"EightClubs": eight_clubs,
		"FiveDiamond": five_diamonds,
		"AceDiamond": ace_diamond
	}
	
	# Iterate over Global.card_states and set the materials
	for card_name in Global.card_states.keys():
		var card = cards[card_name]
		if Global.card_states[card_name]:
			card.material = null  # Selected cards have no shader
			selected_cards_count += 1
		else:
			card.material = bw_shader_material  # Apply shader for unselected cards


func _on_card_mouse_entered(card: Control) -> void:
	if not Global.card_states[card.name]:
		card.material = null
		card.scale += Vector2(0.01, 0.01)

func _on_card_mouse_exited(card: Control) -> void:
	if not Global.card_states[card.name]:
		card.material = bw_shader_material
	card.scale -= Vector2(0.01, 0.01)

func _on_card_gui_input(event: InputEvent, card: Control, card_name: String) -> void:
	if event.is_action_pressed("select"):
		if not Global.card_states[card_name] and selected_cards_count < MAX_SELECTION:
			# Select the card
			Global.card_states[card_name] = true
			card.material = null
			selected_cards_count += 1
			print("Selected: ", card_name, " - Total Selected: ", selected_cards_count)
		elif Global.card_states[card_name]:
			# Deselect the card
			Global.card_states[card_name] = false
			card.material = bw_shader_material
			selected_cards_count -= 1
			print("Deselected: ", card_name, " - Total Selected: ", selected_cards_count)

# Individual Signal Connections
func _on_lightning_one_mouse_entered() -> void: _on_card_mouse_entered(lightning_one)
func _on_lightning_one_mouse_exited() -> void: _on_card_mouse_exited(lightning_one)
func _on_lightning_one_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, lightning_one, "LightningOne")

func _on_lightning_two_mouse_entered() -> void: _on_card_mouse_entered(lightning_two)
func _on_lightning_two_mouse_exited() -> void: _on_card_mouse_exited(lightning_two)
func _on_lightning_two_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, lightning_two, "LightningTwo")

func _on_fire_one_mouse_entered() -> void: _on_card_mouse_entered(fire_one)
func _on_fire_one_mouse_exited() -> void: _on_card_mouse_exited(fire_one)
func _on_fire_one_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, fire_one, "FireOne")

func _on_ice_one_mouse_entered() -> void: _on_card_mouse_entered(ice_one)
func _on_ice_one_mouse_exited() -> void: _on_card_mouse_exited(ice_one)
func _on_ice_one_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, ice_one, "IceOne")

func _on_acid_one_mouse_entered() -> void: _on_card_mouse_entered(acid_one)
func _on_acid_one_mouse_exited() -> void: _on_card_mouse_exited(acid_one)
func _on_acid_one_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, acid_one, "AcidOne")

func _on_acid_two_mouse_entered() -> void: _on_card_mouse_entered(acid_two)
func _on_acid_two_mouse_exited() -> void: _on_card_mouse_exited(acid_two)
func _on_acid_two_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, acid_two, "AcidTwo")

func _on_light_one_mouse_entered() -> void: _on_card_mouse_entered(light_one)
func _on_light_one_mouse_exited() -> void: _on_card_mouse_exited(light_one)
func _on_light_one_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, light_one, "LightOne")

func _on_light_two_mouse_entered() -> void: _on_card_mouse_entered(light_two)
func _on_light_two_mouse_exited() -> void: _on_card_mouse_exited(light_two)
func _on_light_two_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, light_two, "LightTwo")

func _on_ice_two_mouse_entered() -> void: _on_card_mouse_entered(ice_two)
func _on_ice_two_mouse_exited() -> void: _on_card_mouse_exited(ice_two)
func _on_ice_two_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, ice_two, "IceTwo")

func _on_seven_diamond_mouse_entered() -> void: _on_card_mouse_entered(seven_diamond)
func _on_seven_diamond_mouse_exited() -> void: _on_card_mouse_exited(seven_diamond)
func _on_seven_diamond_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, seven_diamond, "SevenDiamond")

func _on_three_hearts_mouse_entered() -> void: _on_card_mouse_entered(three_hearts)
func _on_three_hearts_mouse_exited() -> void: _on_card_mouse_exited(three_hearts)
func _on_three_hearts_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, three_hearts, "ThreeHearts")

func _on_eight_clubs_mouse_entered() -> void: _on_card_mouse_entered(eight_clubs)
func _on_eight_clubs_mouse_exited() -> void: _on_card_mouse_exited(eight_clubs)
func _on_eight_clubs_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, eight_clubs, "EightClubs")

func _on_five_diamond_mouse_entered() -> void: _on_card_mouse_entered(five_diamonds)
func _on_five_diamond_mouse_exited() -> void: _on_card_mouse_exited(five_diamonds)
func _on_five_diamond_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, five_diamonds, "FiveDiamond")

func _on_ace_diamond_mouse_entered() -> void: _on_card_mouse_entered(ace_diamond)
func _on_ace_diamond_mouse_exited() -> void: _on_card_mouse_exited(ace_diamond)
func _on_ace_diamond_gui_input(event: InputEvent) -> void: _on_card_gui_input(event, ace_diamond, "AceDiamond")
