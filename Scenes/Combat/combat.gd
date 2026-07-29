extends Node2D

## Combat scene — medium between Hand, Enemy, and Player.
## State machine: PlayerTurn -> EnemyTurn -> CheckWin -> PlayerTurn ...

@onready var hand   := get_node("Room/Hand")
@onready var enemy  := get_node("Room/Enemy")
@onready var player := get_node("Room/Player")

@onready var player_health_bar: HealthBar = $UI/PlayerHealthBar
@onready var enemy_health_bar:  HealthBar = $UI/EnemyHealthBar

## Game States
enum State { PlayerTurn, EnemyTurn, CheckWin, Frozen }

var current_state: State = State.PlayerTurn

## Player Action Information
var player_card_type: String = "None"
var player_card_damage: int = 0
var player_skipped_turn: bool = false

func _ready() -> void:
	current_state = State.PlayerTurn
	_wire_health_bars()

func _wire_health_bars() -> void:
	# Player
	player_health_bar.setup("You", player.get_max_health(), player.get_health())
	player.health_changed.connect(
		func(hp: int, mx: int): player_health_bar.set_hp(hp)
	)
	# Enemy — variant is picked in Enemy._ready(), which fires before this
	# (since Enemy is a child of Room and added to the tree before Combat's
	# _ready runs). If for some reason the variant isn't ready yet, the
	# variant_ready signal will fire when it is.
	if enemy.get_display_name() != "Enemy":
		enemy_health_bar.setup(enemy.get_display_name(), enemy.max_hp, enemy.get_health())
	enemy.variant_ready.connect(
		func(name: String, mx: int): enemy_health_bar.setup(name, mx, enemy.get_health())
	)
	enemy.health_changed.connect(
		func(hp: int, mx: int): enemy_health_bar.set_hp(hp)
	)

func _process(_delta: float) -> void:
	match current_state:
		State.PlayerTurn:
			player_turn()
		State.EnemyTurn:
			enemy_turn()
		State.CheckWin:
			check_win()
		State.Frozen:
			pass

# -------------------------- Player Turn --------------------------------------
func player_turn() -> void:
	get_card_played()
	hand.toggle_card_selected()

	# Attack card
	if player_card_type != "None" and player_card_damage != 0 and player_card_type != "Deck":
		print("Player played ", player_card_type, " for ", player_card_damage, " damage")
		await enemy.apply_damage(player_card_type, player_card_damage)
		player_skipped_turn = false
		current_state = State.EnemyTurn

	# Deck / skip
	elif player_card_type == "Deck":
		print("Player drew from the deck — turn is skipped, no enemy attack this round.")
		player_skipped_turn = true
		await get_tree().create_timer(0.5).timeout
		current_state = State.EnemyTurn

	# Reset player card info so we don't re-trigger
	player_card_type = "None"
	player_card_damage = 0

# -------------------------- Enemy Turn ---------------------------------------
func enemy_turn() -> void:
	if player_skipped_turn:
		# Playing the Deck card = "I don't act this round", but the enemy STILL
		# gets to attack. Actually, the ORIGINAL intent (per the code) seems to
		# be that Deck skips the WHOLE round. We'll honor that: skip enemy too.
		print("Enemy watches you shuffle. No attack this round.")
		player_skipped_turn = false
	else:
		var enemy_damage: int = enemy.roll_attack()
		await player.apply_damage(enemy_damage)

	current_state = State.CheckWin

# -------------------------- Check Win ----------------------------------------
func check_win() -> void:
	if enemy.get_health() <= 0:
		current_state = State.Frozen
		# Winning combat advances the escape counter.
		Global.rooms_visited += 1

		# Small chance of a reward room after victory.
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		if rng.randf() < 0.4:
			get_tree().change_scene_to_file("res://Scenes/Reward/Reward.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/Navigation/Navigation.tscn")
		return

	if player.get_health() <= 0:
		current_state = State.Frozen
		get_tree().change_scene_to_file("res://Scenes/Death/Death.tscn")
		return

	current_state = State.PlayerTurn

# -------------------------- Card Query ---------------------------------------
func get_card_played() -> void:
	if not hand.get_card_selected():
		player_card_type = "None"
		player_card_damage = 0
		return

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

	if player_card_type != "None":
		print("Card Selected: %s | Damage: %d" % [player_card_type, player_card_damage])
