extends Node2D

var card_one_hovered 	:= false
var card_two_hovered 	:= false
var card_three_hovered 	:= false
var card_deck_hovered 	:= false

var card_one_selected	:= false
var card_two_selected 	:= false
var card_three_selected := false
var card_deck_selected 	:= false

var attack_counter := 0

@onready var card_one 		:= get_node("Room/Hand/CardOne")
@onready var card_two 		:= get_node("Room/Hand/CardTwo")
@onready var card_three 	:= get_node("Room/Hand/CardThree")
@onready var card_deck	 	:= get_node("Room/Hand/Deck")

@onready var enemy 			:= get_node("Room/Enemy")


func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if (attack_counter > 3):
		get_tree().change_scene_to_file("res://Sceens/Navigation/Navigation.tscn") ## Load our Navigation Sceene


# =================================== Card One ===================================

func _on_card_one_top_collission_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		enemy.start_shake_and_wobble()
		print("Card One Selected!")
		attack_counter += 1
		
func _on_card_one_bottom_collission_mouse_entered() -> void:
	card_one_hovered = true
	card_one.scale = Vector2(1.25, 1.25)
	print("Mouse on Card One!")

func _on_card_one_bottom_collission_mouse_exited() -> void:
	card_one_hovered = false
	card_one.scale = Vector2(1.0, 1.0)
	print("Mouse off Card One!")

# =================================== Card Two ===================================

func _on_card_two_bottom_collision_mouse_entered() -> void:
	card_two_hovered = true
	card_two.scale = Vector2(1.25, 1.25)
	print("Mouse on Card Two!")


func _on_card_two_bottom_collision_mouse_exited() -> void:
	card_two_hovered = false
	card_two.scale = Vector2(1.0, 1.0)
	print("Mouse off Card Two!")


func _on_card_two_top_collision_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		enemy.start_shake_and_wobble()
		print("Card Two Selected!")
		attack_counter += 1

# =================================== Card Three ===================================

func _on_card_three_top_collision_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		enemy.start_shake_and_wobble()		
		print("Card Three Selected!")
		attack_counter += 1


func _on_card_three_bottom_collision_mouse_entered() -> void:
	card_three_hovered = true
	card_three.scale = Vector2(1.25, 1.25)
	print("Mouse on Card Three!")

func _on_card_three_bottom_collision_mouse_exited() -> void:
	card_three_hovered = false
	card_three.scale = Vector2(1.0, 1.0)
	print("Mouse off Card Three!")

# =================================== Deck of Cards ===================================

func _on_deck_collision_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		print("Deck of Cards Selected!")

func _on_deck_collision_mouse_entered() -> void:
	card_deck_hovered = true
	card_deck.scale = Vector2(1.25, 1.25)
	print("Mouse on Deck of Cards!")

func _on_deck_collision_mouse_exited() -> void:
	card_deck_hovered = false
	card_deck.scale = Vector2(1.0, 1.0)
	print("Mouse off Deck of Cards!")
