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

@onready var card_one 		:= get_node("CardOne")
@onready var card_two 		:= get_node("CardTwo")
@onready var card_three 	:= get_node("CardThree")
@onready var card_deck	 	:= get_node("Deck")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

# =================================== Getters  ===================================
func get_card_one_selected() -> bool:
	return card_one_selected

func get_card_two_selected() -> bool:
	return card_two_selected

func get_card_three_selected() -> bool:
	return card_three_selected

func get_card_deck_selected() -> bool:
	return card_deck_selected

func get_card_selected() -> bool:
	return card_selected
	
func toggle_card_selected():
	if card_selected: 
		card_selected = false
		card_one_selected = false
		card_two_selected = false
		card_three_selected = false
		card_deck_selected = false

	else: card_selected = true
	
	
## TODO! For the below getters, we need to work on randomizing the type and damage a bit later.
func get_card_one_type():
	return "Fire"

func get_card_two_type():
	return "Lightning"
	
func get_card_three_type():
	return "Acid"

func get_card_one_damage():
	return 30

func get_card_two_damage():
	return 30

func get_card_three_damage():
	return 30

# =================================== Card One ===================================
func _on_card_one_top_collission_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		#print("Card One Selected!")
		if card_selected == false:
			card_one_selected = true
			card_selected = true
		
func _on_card_one_bottom_collission_mouse_entered() -> void:
	card_one_hovered = true
	card_one.scale = Vector2(1.25, 1.25)
	#print("Mouse on Card One!")

func _on_card_one_bottom_collission_mouse_exited() -> void:
	card_one_hovered = false
	card_one.scale = Vector2(1.0, 1.0)
	#print("Mouse off Card One!")

# =================================== Card Two ===================================
func _on_card_two_top_collision_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		#print("Card Two Selected!")
		if card_selected == false:
			card_two_selected = true
			card_selected = true

func _on_card_two_bottom_collision_mouse_entered() -> void:
	card_two_hovered = true
	card_two.scale = Vector2(1.25, 1.25)
	#print("Mouse on Card Two!")


func _on_card_two_bottom_collision_mouse_exited() -> void:
	card_two_hovered = false
	card_two.scale = Vector2(1.0, 1.0)
	#print("Mouse off Card Two!")

# =================================== Card Three ===================================

func _on_card_three_top_collision_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		#print("Card Three Selected!")
		if card_selected == false:
			card_three_selected = true
			card_selected = true


func _on_card_three_bottom_collision_mouse_entered() -> void:
	card_three_hovered = true
	card_three.scale = Vector2(1.25, 1.25)
	#print("Mouse on Card Three!")

func _on_card_three_bottom_collision_mouse_exited() -> void:
	card_three_hovered = false
	card_three.scale = Vector2(1.0, 1.0)
	#print("Mouse off Card Three!")

# =================================== Deck of Cards ===================================
func _on_deck_collision_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		if card_selected == false:
			card_deck_selected = true
			card_selected = true
			print("Deck of Cards Selected!")

func _on_deck_collision_mouse_entered() -> void:
	card_deck_hovered = true
	card_deck.scale = Vector2(1.25, 1.25)
	#print("Mouse on Deck of Cards!")

func _on_deck_collision_mouse_exited() -> void:
	card_deck_hovered = false
	card_deck.scale = Vector2(1.0, 1.0)
	#print("Mouse off Deck of Cards!")
