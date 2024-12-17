extends Sprite2D


## Used to make the card larger on hover.
var card_one_hovered 	:= false
var card_two_hovered 	:= false
var card_three_hovered 	:= false
var card_deck_hovered 	:= false

## Used to Preform the Next Action.
var card_one_selected	:= false
var card_two_selected 	:= false
var card_three_selected := false
var card_deck_selected 	:= false
var card_selected	 	:= false

## Capture Nodes
@onready var card_one		= null
@onready var card_two		= null
@onready var card_three		= null
@onready var card_deck	 	:= get_node("Deck")
var all_playable_cards = []
var loaded_playable_cards = []
var selected_playable_cards = []

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	
	register_playable_cards()
	load_playable_cards()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func register_playable_cards() -> void:
	var cards = Global.card_states
	# Parse into individual variables
	for card_name in cards.keys():
		if (cards[card_name]):
			if card_name == "LightningOne": all_playable_cards.append("res://Sceens/Cards/lightning_one.tscn")
			if card_name == "LightningTwo": all_playable_cards.append("res://Sceens/Cards/lightning_two.tscn")
			if card_name == "FireOne": all_playable_cards.append("res://Sceens/Cards/fire_one.tscn")
			if card_name == "IceOne": all_playable_cards.append("res://Sceens/Cards/ice_one.tscn")
			if card_name == "AcidOne": all_playable_cards.append("res://Sceens/Cards/acid_one.tscn")
			if card_name == "AcidTwo": all_playable_cards.append("res://Sceens/Cards/acid_two.tscn")
			if card_name == "LightOne": all_playable_cards.append("res://Sceens/Cards/light_one.tscn")
			if card_name == "LightTwo": all_playable_cards.append("res://Sceens/Cards/light_two.tscn")
			if card_name == "IceTwo": all_playable_cards.append("res://Sceens/Cards/ice_two.tscn")
			if card_name == "SevenDiamond": all_playable_cards.append("res://Sceens/Cards/seven_diamonds.tscn")
			if card_name == "ThreeHearts": all_playable_cards.append("res://Sceens/Cards/three_hearts.tscn")
			if card_name == "EightClubs": all_playable_cards.append("res://Sceens/Cards/eight_clubs.tscn")
			if card_name == "FiveDiamond": all_playable_cards.append("res://Sceens/Cards/five_diamonds.tscn")
			if card_name == "AceDiamond": all_playable_cards.append("res://Sceens/Cards/ace_diamonds.tscn")

func load_playable_cards() -> void:
	for card in all_playable_cards:
		loaded_playable_cards.append(card)
	
	var playable_cards_length = loaded_playable_cards.size()
	while(selected_playable_cards.size() < 3):
		selected_playable_cards.append(rng.randi_range(0, (playable_cards_length-1)))
		
	var card_one_scene = load(loaded_playable_cards[selected_playable_cards[0]])  # Load the resource
	var card_two_scene = load(loaded_playable_cards[selected_playable_cards[1]])
	var card_three_scene = load(loaded_playable_cards[selected_playable_cards[2]])

	if card_one_scene is PackedScene:  # Ensure it's a PackedScene
		card_one = card_one_scene.instantiate()  # Instantiate the scene
		card_one.position = Vector2(-319,920)
		card_one.rotation = deg_to_rad(-12)
		add_child(card_one)  # Add the instantiated node to the tree
	else:
		print("Error: The resource at ", loaded_playable_cards[selected_playable_cards[0]], " is not a PackedScene.")

	if card_two_scene is PackedScene:  # Ensure it's a PackedScene
		card_two = card_two_scene.instantiate()  # Instantiate the scene
		card_two.position = Vector2(-109,920)
		card_two.rotation = deg_to_rad(0)
		add_child(card_two)  # Add the instantiated node to the tree
	else:
		print("Error: The resource at ", loaded_playable_cards[selected_playable_cards[1]], " is not a PackedScene.")

	if card_three_scene is PackedScene:  # Ensure it's a PackedScene
		card_three = card_three_scene.instantiate()  # Instantiate the scene
		card_three.position = Vector2(100,920)
		card_three.rotation = deg_to_rad(12)
		add_child(card_three)  # Add the instantiated node to the tree
	else:
		print("Error: The resource at ", loaded_playable_cards[selected_playable_cards[2]], " is not a PackedScene.")
	
# Combat.gd requires the following signatures
#hand.toggle_card_selected()
#hand.get_card_selected():

#hand.get_card_one_selected()
#hand.get_card_one_type()
#hand.get_card_one_damage()
#
#hand.get_card_two_selected()
#hand.get_card_two_type()
#hand.get_card_two_damage()
#
#hand.get_card_three_selected()
#hand.get_card_three_type()
#hand.get_card_three_damage()
#
#hand.get_card_deck_selected()

func get_card_selected() -> bool:
	return card_selected
	
func toggle_card_selected():
	if card_selected:
		card_one.selected = false
		card_two.selected = false
		card_three.selected = false
		card_deck_selected = false

		card_selected = false
	else:
		card_selected = true

# ===================================== Card One ========================================
func get_card_one_selected() -> bool:
	card_selected = true
	return card_one.selected

func get_card_one_type():
	return card_one.card_type

func get_card_one_damage() -> int:
	return card_one.card_damage

# ===================================== Card Two ========================================
func get_card_two_selected() -> bool:
	card_selected = true
	return card_two.selected

func get_card_two_type():
	return card_two.card_type

func get_card_two_damage():
	return card_two.card_damage

# ===================================== Card Three ========================================
func get_card_three_selected() -> bool:
	card_selected = true
	return card_three.selected

func get_card_three_type():
	return card_three.card_type

func get_card_three_damage():
	return card_three.card_damage

# ===================================== Card Deck ========================================
func get_card_deck_selected():
	card_selected = true
	return card_deck_selected




















# =================================== Getters  ===================================
#func get_card_one_selected() -> bool:
	#card_selected = card_one.selected
	#return card_one.selected
#
#func get_card_two_selected() -> bool:
	#card_selected = card_two.selected
	#return card_two.selected
#
#func get_card_three_selected() -> bool:
	#card_selected = card_three.selected
	#return card_three.selected
#
#func get_card_deck_selected() -> bool:
	#return card_deck_selected
#
#func get_card_selected() -> bool:
	#return card_selected
	#
#func toggle_card_selected():
	#if card_selected: 
		#card_selected = false
		#card_one_selected = false
		#card_two_selected = false
		#card_three_selected = false
		#card_deck_selected = false
#
	#else: card_selected = true
#
#func get_card_one_type():
	#return card_one.card_type
#
#func get_card_two_type():
	#return card_two.card_type
	#
#func get_card_three_type():
	#return card_three.card_type
#
#func get_card_one_damage():
	#return card_one.card_damage
#
#func get_card_two_damage():
	#return card_two.card_damage
#
#func get_card_three_damage():
	#return card_three.card_damage
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
## =================================== Input  ===================================
#func _on_card_one_collission_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#if event.is_action_pressed("select"): # set this up in project settings
		##print("Card One Selected!")
		#if card_selected == false:
			#card_one_selected = true
			#card_selected = true
#
#func _on_card_two_collission_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#if event.is_action_pressed("select"): # set this up in project settings
		##print("Card One Selected!")
		#if card_selected == false:
			#card_two_selected = true
			#card_selected = true
#
#func _on_card_three_collission_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#if event.is_action_pressed("select"): # set this up in project settings
		##print("Card One Selected!")
		#if card_selected == false:
			#card_three_selected = true
			#card_selected = true
#
## =================================== Scale Up / Down  ===================================
## Generic Signal Handlers
#func _on_card_mouse_entered(card: Node) -> void:
	#card.scale += Vector2(0.05, 0.05)
#
#func _on_card_mouse_exited(card: Node) -> void:
	#card.scale -= Vector2(0.05, 0.05)
#

func _on_deck_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		#print("Card One Selected!")
		toggle_card_selected()
		card_deck_selected = true

func _on_deck_area_2d_mouse_entered() -> void:
	card_deck_hovered = true
	card_deck.scale = Vector2(0.40, 0.40)

func _on_deck_area_2d_mouse_exited() -> void:
	card_deck_hovered = false
	card_deck.scale = Vector2(0.35, 0.35)
