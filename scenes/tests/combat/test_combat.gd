extends Node2D

enum CombatState {
	PLAYERS_TURN,
	ENEMYS_TURN,
	CHECK_WIN,
}

@onready var state: CombatState = CombatState.PLAYERS_TURN
@onready var player_hand = get_node("PlayersHand")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		CombatState.PLAYERS_TURN:
			if player_hand.card_dropped == true:
				# Do Damage to Enemy
				# Change Hand or Refil Card
				# Change State to Enemy
				state = CombatState.ENEMYS_TURN
				pass
			
			pass
		CombatState.ENEMYS_TURN:
			# Zero Out player_hand.card_dropped and card information
			
			# Get Random Action from Enemy
			# Apply damage to Player
			# Change State to Check Win
			pass
		CombatState.CHECK_WIN:
			# Check Player Health Above Zero
			# Check Enemy Health Above Zero
			# Change to Players Turn
			pass
