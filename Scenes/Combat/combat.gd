extends Node2D

## Combat scene — full deckbuilder loop.
##
## Turn flow:
##   1. Player Turn starts — Hand draws 5.
##   2. Player clicks ONE card. Whole hand vanishes, damage lands.
##   3. Wait for healthbar drain + 0.3s beat.
##   4. Enemy lurches, hits the player, recoils.
##   5. New player turn — draw 5.
##
## The player can also click the Deck sprite to skip the play and end
## the turn early (useful if their hand is bad).

@onready var hand:   Node2D = get_node("Room/Hand")
@onready var enemy         = get_node("Room/Enemy")
@onready var player        = get_node("Room/Player")

@onready var player_health_bar: HealthBar = $UI/PlayerHealthBar
@onready var enemy_health_bar:  HealthBar = $UI/EnemyHealthBar
# Optional counters label — may be absent if the scene was edited.
@onready var pile_counters:     Label     = get_node_or_null("UI/PileCounters")

enum State { PlayerTurn, EnemyTurn, ResolvingCard, Frozen }
var current_state: State = State.PlayerTurn

func _ready() -> void:
	_wire_health_bars()
	_wire_hand()

	# Kick off the very first turn.
	current_state = State.PlayerTurn
	hand.start_turn()

# ============================================================================
# Wiring
# ============================================================================
func _wire_health_bars() -> void:
	player_health_bar.setup("You", player.get_max_health(), player.get_health())
	player.health_changed.connect(
		func(hp: int, _mx: int): player_health_bar.set_hp(hp)
	)

	if enemy.get_display_name() != "Enemy":
		enemy_health_bar.setup(enemy.get_display_name(), enemy.max_hp, enemy.get_health())
	enemy.variant_ready.connect(
		func(_name: String, _mx: int): enemy_health_bar.setup(enemy.get_display_name(), enemy.max_hp, enemy.get_health())
	)
	enemy.health_changed.connect(
		func(hp: int, _mx: int): enemy_health_bar.set_hp(hp)
	)

func _wire_hand() -> void:
	hand.card_played.connect(_on_card_played)
	hand.piles_changed.connect(_on_piles_changed)
	hand.end_turn_requested.connect(_on_end_turn_requested)

# ============================================================================
# Card play resolution
# ============================================================================
func _on_card_played(card_type: String, card_damage: int) -> void:
	print("[Combat] _on_card_played: state=%d type=%s dmg=%d" % [current_state, card_type, card_damage])
	if current_state != State.PlayerTurn:
		print("[Combat] ignoring card_played — not in PlayerTurn")
		return
	current_state = State.ResolvingCard

	# Give the eye a beat to register that the cards vanished before the hit.
	await get_tree().create_timer(0.25).timeout

	if card_type == "Defend":
		print("[Combat] Defend played — blocking the next enemy hit")
		player.add_block()
	elif card_damage > 0 and card_type != "None":
		print("[Combat] applying %d %s damage to enemy" % [card_damage, card_type])
		enemy.apply_damage(card_type, card_damage)
		# Wait for the enemy's healthbar to finish draining.
		await enemy_health_bar.await_settled()

	# Check for enemy death first — if it died, don't let it swing back.
	if enemy.get_health() <= 0:
		_check_end_of_combat()
		return

	# The requested 0.3s pause before the enemy retaliates.
	await get_tree().create_timer(0.3).timeout

	# Now the enemy lurches and hits the player.
	await _do_end_of_turn()

# ============================================================================
# End Turn (via Deck click)
# ============================================================================
func _on_end_turn_requested() -> void:
	print("[Combat] end-turn requested: state=%d" % current_state)
	if current_state != State.PlayerTurn:
		return
	await _do_end_of_turn()

# Shared end-of-turn flow: discard hand, enemy attacks, draw new hand.
func _do_end_of_turn() -> void:
	print("[Combat] _do_end_of_turn — enemy attacking")
	current_state = State.EnemyTurn

	hand.end_turn()  # discard the hand (no-op after a card play — already cleared)

	# Enemy attacks: roll the damage first, then animate the lurch. Player
	# damage lands on the "lurch_impact" signal at the peak of the lunge.
	var enemy_damage: int = enemy.roll_attack()

	# One-shot connect so we can fire damage on impact then disconnect cleanly.
	var impact_callable := func():
		player.apply_damage(enemy_damage)
	enemy.lurch_impact.connect(impact_callable, CONNECT_ONE_SHOT)

	await enemy.lurch_and_recoil()

	# Let the player's healthbar finish draining before checking outcomes.
	await player_health_bar.await_settled()
	await get_tree().create_timer(0.25).timeout

	if _check_end_of_combat():
		return

	# New player turn — draw fresh hand.
	print("[Combat] enemy done — starting next player turn")
	current_state = State.PlayerTurn
	hand.start_turn()
	print("[Combat] next turn started; state=%d" % current_state)

# ============================================================================
# End of combat check
# ============================================================================
func _check_end_of_combat() -> bool:
	if enemy.get_health() <= 0:
		current_state = State.Frozen
		Global.rooms_visited += 1
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		if rng.randf() < 0.4:
			get_tree().change_scene_to_file("res://Scenes/Reward/Reward.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/Navigation/Navigation.tscn")
		return true

	if player.get_health() <= 0:
		current_state = State.Frozen
		get_tree().change_scene_to_file("res://Scenes/Death/Death.tscn")
		return true

	return false

# ============================================================================
# UI updates (safe if PileCounters label was deleted)
# ============================================================================
func _on_piles_changed(draw_count: int, _hand_count: int, discard_count: int) -> void:
	if pile_counters:
		pile_counters.text = "Draw: %d    Discard: %d" % [draw_count, discard_count]
