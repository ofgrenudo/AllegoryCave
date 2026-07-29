extends Node2D

## Combat scene — full deckbuilder loop.
##
## Turn flow:
##   1. Player Turn starts — Hand draws up to HAND_SIZE cards.
##   2. Player clicks any number of cards; each resolves via the
##      Hand.card_played signal. Between cards, we return to the
##      same player-turn state (unlock input, keep drawing/playing).
##   3. Player clicks END TURN — remaining hand is discarded, enemy
##      takes its turn, then a new player turn begins.
##   4. When the draw pile empties, discard is shuffled back in.

@onready var hand:   Node2D = get_node("Room/Hand")
@onready var enemy         = get_node("Room/Enemy")
@onready var player        = get_node("Room/Player")

@onready var player_health_bar: HealthBar = $UI/PlayerHealthBar
@onready var enemy_health_bar:  HealthBar = $UI/EnemyHealthBar
@onready var end_turn_button:   Button    = $UI/EndTurnButton
@onready var pile_counters:     Label     = $UI/PileCounters

enum State { PlayerTurn, EnemyTurn, ResolvingCard, Frozen }
var current_state: State = State.PlayerTurn

func _ready() -> void:
	_wire_health_bars()
	_wire_hand()
	_wire_end_turn_button()

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
		func(name: String, mx: int): enemy_health_bar.setup(name, mx, enemy.get_health())
	)
	enemy.health_changed.connect(
		func(hp: int, _mx: int): enemy_health_bar.set_hp(hp)
	)

func _wire_hand() -> void:
	hand.card_played.connect(_on_card_played)
	hand.piles_changed.connect(_on_piles_changed)

func _wire_end_turn_button() -> void:
	end_turn_button.pressed.connect(_on_end_turn_pressed)

# ============================================================================
# Card play resolution
# ============================================================================
func _on_card_played(card_type: String, card_damage: int) -> void:
	if current_state != State.PlayerTurn:
		return
	current_state = State.ResolvingCard

	# The hand has already cleared every card when this signal fires — the
	# played card and any remaining ones are already in the discard pile.
	# So now we just resolve the damage and let the player watch it land.

	# Give the eye a beat to register that the cards vanished before the hit.
	await get_tree().create_timer(0.25).timeout

	if card_damage > 0 and card_type != "None":
		print("Player played %s for %d damage" % [card_type, card_damage])
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
# End Turn button
# ============================================================================
func _on_end_turn_pressed() -> void:
	if current_state != State.PlayerTurn:
		return
	await _do_end_of_turn()

# Shared end-of-turn flow, used by both the END TURN button (no card played)
# and the auto-end after a card resolves.
func _do_end_of_turn() -> void:
	current_state = State.EnemyTurn
	end_turn_button.disabled = true

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
	current_state = State.PlayerTurn
	end_turn_button.disabled = false
	hand.start_turn()

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
# UI updates
# ============================================================================
func _on_piles_changed(draw_count: int, _hand_count: int, discard_count: int) -> void:
	pile_counters.text = "Draw: %d    Discard: %d" % [draw_count, discard_count]
