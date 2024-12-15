extends Node2D

@onready var nav_left = get_node("left")
@onready var nav_right = get_node("right")
@onready var nav_forward_left = get_node("forward_left")
@onready var nav_forward_right = get_node("forward_right")
@onready var nav_left_or_right_1 = get_node("left_or_right_1")
@onready var nav_left_or_right_2 = get_node("left_or_right_2")

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
	rng.randomize()
	var new_navigation_random_number = rng.randi_range(0, navigation_array_size)
	var combat_encounter_chance = rng.randi_range(0, 1000)
		
	if (first_run):
		combat_encounter_chance = combat_encounter_chance - 650
		first_run = false

	if (new_navigation_random_number == navigation_random_number):
		rng.randomize()
		navigation_random_number = rng.randi_range(0, navigation_array_size)
	else:
		navigation_random_number = new_navigation_random_number

	print("\nNavigation Combat Encounter = ", combat_encounter_chance)
	print("Navigation Random Number = ", navigation_random_number)

	if (combat_encounter_chance > 750):
		#await get_tree().change_scene_to_packed(preloaded_combat_sceen)
		get_tree().change_scene_to_file("res://Sceens/Combat/Combat.tscn")
	else:
		for index in navigation_array_size:
			navigation_options[index].visible = false

			rng.randomize()
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
