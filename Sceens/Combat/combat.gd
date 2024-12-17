extends Node2D

## This class acts as a medium between the Hand, Enemy, and Player.
## It keeps track of the game states and processes turns.

@onready var hand 	:= get_node("Room/Hand")
@onready var enemy 	:= get_node("Room/Enemy")
@onready var player	:= get_node("Room/Player")
@onready var preload_combat_sceene := preload("res://Sceens/Navigation/Navigation.tscn")
@onready var preload_main_menu_sceene := preload("res://Sceens/Main Menu.tscn")

## Game States
enum State { PlayerTurn, EnemyTurn, CheckWin }

var current_state: State = State.PlayerTurn

## Player Action Information
var player_card_type: String = "None"
var player_card_damage: int = 0

func _ready() -> void:
	current_state = State.PlayerTurn

func _process(_delta: float) -> void:
	match current_state:
		State.PlayerTurn:
			player_turn()
		State.EnemyTurn:
			enemy_turn()
		State.CheckWin:
			check_win()

# Player's Turn
func player_turn() -> void:
	# Get the selected card
	get_card_played()
	hand.toggle_card_selected()

	# If a valid attack card is played
	if player_card_type != "None" and player_card_damage != 0:
		print("Player Card Type -> ", player_card_type, " and Player Card Damage -> ", player_card_damage)
		await enemy.apply_damage(player_card_type, player_card_damage)
		current_state = State.EnemyTurn

	# If the Deck card is played
	elif player_card_type == "Deck":
		print("Player drew from the deck.")
		await get_tree().create_timer(1.0).timeout
		current_state = State.EnemyTurn

	# Reset player card info to prevent re-triggering
	player_card_type = "None"
	player_card_damage = 0


# Enemy's Turn
func enemy_turn() -> void:
	## Apply damage to the player
	var enemy_damage = 15	
	await player.apply_damage(enemy_damage)

	if ((player_card_type == "Deck")):
		## Reset player card info
		player_card_type = "None"
		player_card_damage = 0

	## Pass turn to the check-win state
	current_state = State.CheckWin

# Check for game over or proceed to the next turn
func check_win() -> void:
	if enemy.get_health() <= 0:
		# Load Navigation scene (victory)
		get_tree().change_scene_to_file("res://Sceens/Navigation/Navigation.tscn")
		return

	if player.get_health() <= 0:
		# TODO: Create a death scene
		get_tree().change_scene_to_packed(preload_main_menu_sceene)
		return

	# If no one has won, return to the player's turn
	current_state = State.PlayerTurn


# Get the card information from the hand
func get_card_played() -> void:
	#print(hand.get_card_selected())
	if hand.get_card_selected():
		if hand.get_card_one_selected():
			player_card_type = hand.get_card_one_type()
			player_card_damage = hand.get_card_one_damage()

		elif hand.get_card_two_selected():
			player_card_type = hand.get_card_two_type()
			player_card_damage = hand.get_card_two_damage()

		elif hand.get_card_three_selected():
			player_card_type = hand.get_card_three_type()
			player_card_damage = hand.get_card_three_damage()

		elif hand.get_card_deck_selected():
			player_card_type = "Deck"
			player_card_damage = 0
		
		if !(player_card_type == "None"):
			print("Card Selected: ", player_card_type, " Card Damage: ", player_card_damage, "\n\n")

	else:
		player_card_type = "None"
		player_card_damage = 0
