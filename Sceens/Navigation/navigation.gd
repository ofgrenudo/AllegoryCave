extends Node2D

@onready var nav_left = get_node("left")
@onready var nav_right = get_node("right")
@onready var nav_forward_left = get_node("forward_left")
@onready var nav_forward_right = get_node("forward_right")
@onready var nav_left_or_right_1 = get_node("left_or_right_1")
@onready var nav_left_or_right_2 = get_node("left_or_right_2")
@onready var card_deck	 	:= get_node("Deck")
@onready var deck_manager 	:= get_node("DeckManager")


@onready var navigation_options = [nav_left, nav_right, nav_forward_left, nav_forward_right, nav_left_or_right_1, nav_left_or_right_2]
@onready var navigation_array_size = navigation_options.size() - 1
@onready var navigation_random_number = 0

@onready var preloaded_combat_sceen = preload("res://Sceens/Combat/Combat.tscn")
@onready var first_run = true

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	navigate_rooms()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func navigate_rooms():
	## Make all Sceens Not Visible. This needs to run in the beginning of the
	## function because at times it doesnt complete before you display the room you selected.
	for index in navigation_array_size:
			navigation_options[index].visible = false


	## Randomize the Generator with a time based seed.
	rng.randomize()

	## Generate the Probability or a combat encounter.
	var combat_encounter_chance = rng.randi_range(0, 1000)
	## Nerf the possbility of a combat encounter after you immediately leave
	## a combat sceene
	if (first_run):
		## Take whatever chance we generated and remove over half of it.
		combat_encounter_chance = combat_encounter_chance - 650
		first_run = false



	## Generate a New Random Room Number from 0 to Navigation Array Size.
	var new_navigation_random_number = rng.randi_range(0, navigation_array_size)
	## Make sure that the newly generated number isnt the number that we already have.
	if (new_navigation_random_number == navigation_random_number):
		## Remake the number this time, assign it directly.
		navigation_random_number = rng.randi_range(0, navigation_array_size)
	## The generated number is unique, we will apply it here.
	else:
		navigation_random_number = new_navigation_random_number

	## For Debugging the Navigation Sceene, print out our important information
	print("\nNavigation Combat Encounter = ", combat_encounter_chance)
	print("Navigation Random Number = ", navigation_random_number)


	## From here below, we will begin setting the sceene appropriately
	## If our combat encounter is greater than 750, we will enter combat.
	if (combat_encounter_chance > 750):
		#await get_tree().change_scene_to_packed(preloaded_combat_sceen)
		get_tree().change_scene_to_file("res://Sceens/Combat/Combat.tscn")
	## set the appropriate room to visible.
	else:
		navigation_options[navigation_random_number].visible = true

func _on_left_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		navigate_rooms() # Replace with function body.

func _on_right_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		navigate_rooms() # Replace with function body.

func _on_forward_left_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		navigate_rooms() # Replace with function body.

func _on_forward_right_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		navigate_rooms() # Replace with function body.

func _on_left_or_right_area_one_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		navigate_rooms() # Replace with function body.

func _on_left_or_right_area_two_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		navigate_rooms() # Replace with function body.


func _on_deck_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (deck_manager.visible):
		if event.is_action_pressed("select"): # set this up in project settings
			deck_manager.visible = false
	else:
		if event.is_action_pressed("select"): # set this up in project settings
			deck_manager.visible = true
		
		
func _on_deck_area_2d_mouse_entered() -> void:
	card_deck.scale = Vector2(0.20, 0.20)

func _on_deck_area_2d_mouse_exited() -> void:
	card_deck.scale = Vector2(0.15, 0.15)
