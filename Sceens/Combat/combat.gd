extends Node2D

## This class essentially acts as a medium between the Hand, Enemy, and Player.
## It should on delta process any changes in either of the programs. It should 
## also keep track of whos turn it is.

@onready var hand 	:= get_node("Room/Hand")
@onready var enemy 	:= get_node("Room/Enemy")
@onready var player	:= get_node("Room/Player") 

## Always make the player move first. We can adjust this later easily...
var player_turn := true

## Player Action Information
var player_card_type : String = "None"
var player_card_damage : int = 0

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if enemy.get_health() >= 0: pass
	else: player_turn = false
	
	if (player_turn):
		get_card_played() ## Get Info From Hand
		hand.toggle_card_selected()  ## Clear Info From Hand
		
		## Apply Damage to Enemy
		## The keyword await, ensures that the function is completed before
		## moving forward. Without it, the enemy gets stuck taking damage over 
		## and over.
		await enemy.apply_damage(player_card_type, player_card_damage)
		## TODO! Apply Damage to Player
	else:
		get_tree().change_scene_to_file("res://Sceens/Navigation/Navigation.tscn") ## Load our Navigation Sceene
	
	## At the end of the game loop, empty out card actions
	player_card_type = "None"
	player_card_damage = 0
	

func get_card_played():
	if (hand.get_card_selected()):
		var card_one_selected	 :bool = hand.get_card_one_selected()
		var card_two_selected 	 :bool = hand.get_card_two_selected()
		var card_three_selected	 :bool = hand.get_card_three_selected()
		var card_deck_selected 	 :bool = hand.get_card_deck_selected()
		
		if (card_one_selected):
			player_card_type 	= hand.get_card_one_type()
			player_card_damage 	= hand.get_card_one_damage()

		if (card_two_selected):
			player_card_type 	= hand.get_card_two_type()
			player_card_damage 	= hand.get_card_two_damage()

		if (card_three_selected):
			player_card_type 	= hand.get_card_three_type()
			player_card_damage 	= hand.get_card_three_damage()
			
		if (card_deck_selected):
			player_card_type 	= "Deck"
			player_card_damage	= 0

		#print("Player Card Type ", player_card_type)
		#print("Player Card Damage ", player_card_damage)

	pass
