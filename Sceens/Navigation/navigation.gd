extends Node2D

@onready var navigation_preload = preload("res://Sceens/Navigation/Navigation.tscn")
@onready var combat_preload = preload("res://Sceens/Combat/Combat.tscn")
@onready var hallway = get_node("Hall Way")
@onready var left_or_right = get_node("Left Or Right")

var chance = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	chance = rng.randi_range(1, 100)
	if (chance > 50):
		print("Hallway ", chance)
		hallway.visible = true
	else :
		print("Left Or Right ", chance)
		left_or_right.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (hallway.visible == false && left_or_right.visible == false):
		if (chance > 50):
			print("Hallway ", chance)
			hallway.visible = true
		else :
			print("Left Or Right ", chance)
			left_or_right.visible = true

func _on_onward_pressed() -> void:
	navigate_room()

func _on_left_pressed() -> void:
	navigate_room()

func _on_right_pressed() -> void:
	navigate_room()

func navigate_room() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var chance = rng.randi_range(1, 1000)
	
	if (chance > 800):
		## Do Special Event like chest or  trap.
		## For now we will just reload.
		get_tree().change_scene_to_file("res://Sceens/Navigation/Navigation.tscn") ## Load our Navigation Sceene
	else:
		get_tree().change_scene_to_packed(combat_preload)
