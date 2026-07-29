extends Node2D

## Navigation — pick a random room to display, with a chance of triggering
## combat or a reward room. Tracks Global.rooms_visited toward escape.

@onready var nav_left              = get_node("left")
@onready var nav_right             = get_node("right")
@onready var nav_forward_left      = get_node("forward_left")
@onready var nav_forward_right     = get_node("forward_right")
@onready var nav_left_or_right_1   = get_node("left_or_right_1")
@onready var nav_left_or_right_2   = get_node("left_or_right_2")
@onready var card_deck             = get_node("Deck")
@onready var deck_manager          = get_node("DeckManager")

@onready var navigation_options = [
	nav_left, nav_right, nav_forward_left, nav_forward_right,
	nav_left_or_right_1, nav_left_or_right_2,
]

var last_room_index: int = -1

# Deck-manager shake
var deck_manager_original_position: Vector2
var deck_manager_position: Vector2
var shake_duration: float = 0.5
var shake_strength: float = 10.0
var shaking: bool = false

# Combat chance nerf right after leaving combat
var first_run_since_combat: bool = true

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	deck_manager_original_position = deck_manager.position
	navigate_rooms()

func _process(delta: float) -> void:
	if shaking:
		shake_duration -= delta
		if shake_duration > 0:
			deck_manager.position = deck_manager_position + Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength),
			)
		else:
			shaking = false
			deck_manager.position = deck_manager_original_position

func _unhandled_input(event: InputEvent) -> void:
	# Don't accept navigation input while the deck manager is open.
	if deck_manager.visible:
		# B / Escape closes the deck manager if the deck is legal.
		if event.is_action_pressed("back"):
			var cards_in_play: int = Global.count_selected_cards()
			if cards_in_play >= Global.MIN_DECK_SIZE and cards_in_play <= Global.MAX_DECK_SIZE:
				deck_manager.visible = false
			else:
				start_shake_deck_manager()
			var vp = get_viewport()
			if vp:
				vp.set_input_as_handled()
		return

	# Left/right on any direction input navigates rooms.
	# This catches: D-pad, left stick, WASD, arrow keys — all via nav_left / nav_right.
	# Mouse clicks are excluded here — "select" is bound to the left mouse
	# button, and each clickable sprite (rooms, Deck) already handles clicks
	# itself via its own Area2D input_event. Letting a raw mouse click also
	# fall through this blanket check races the Deck button: physics picking
	# resolves the Area2D click a tick after this fires, so clicking Deck
	# would navigate to the next room before the deck manager got a chance
	# to open.
	if event is InputEventMouseButton:
		return

	if event.is_action_pressed("nav_left") or event.is_action_pressed("nav_right") \
			or event.is_action_pressed("select"):
		navigate_rooms()
		var vp = get_viewport()
		if vp:
			vp.set_input_as_handled()

func navigate_rooms() -> void:
	# Hide every room.
	for room in navigation_options:
		room.visible = false

	# Count this room toward escape progress; if we've hit the goal, win.
	Global.rooms_visited += 1
	if Global.rooms_visited >= Global.ROOMS_TO_ESCAPE:
		get_tree().change_scene_to_file("res://Scenes/Escape/Escape.tscn")
		return

	# Roll for combat / reward / normal room.
	var combat_chance: int = rng.randi_range(0, 1000)
	if first_run_since_combat:
		combat_chance -= 650  # nerf right after leaving combat
		first_run_since_combat = false

	var reward_chance: int = rng.randi_range(0, 1000)

	print("[Nav] room %d/%d  combat_roll=%d  reward_roll=%d" % [
		Global.rooms_visited, Global.ROOMS_TO_ESCAPE, combat_chance, reward_chance,
	])

	if combat_chance > 750:
		first_run_since_combat = true  # nerf next nav after combat resolves
		get_tree().change_scene_to_file("res://Scenes/Combat/Combat.tscn")
		return

	if reward_chance > 950:
		get_tree().change_scene_to_file("res://Scenes/Reward/Reward.tscn")
		return

	# Pick a NEW room, guaranteed different from the last one shown.
	var new_index := rng.randi_range(0, navigation_options.size() - 1)
	if navigation_options.size() > 1:
		while new_index == last_room_index:
			new_index = rng.randi_range(0, navigation_options.size() - 1)
	last_room_index = new_index

	navigation_options[new_index].visible = true

# ------------------------- Room-click signals --------------------------------
func _on_left_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): navigate_rooms()

func _on_right_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): navigate_rooms()

func _on_forward_left_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): navigate_rooms()

func _on_forward_right_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): navigate_rooms()

func _on_left_or_right_area_one_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): navigate_rooms()

func _on_left_or_right_area_two_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): navigate_rooms()

# ------------------------- Deck manager overlay ------------------------------
func _on_deck_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not event.is_action_pressed("select"):
		return

	var cards_in_play: int = Global.count_selected_cards()

	if deck_manager.visible:
		# Enforce MIN / MAX before allowing the player to close the manager.
		if cards_in_play >= Global.MIN_DECK_SIZE and cards_in_play <= Global.MAX_DECK_SIZE:
			deck_manager.visible = false
		else:
			print("Deck size %d out of range [%d..%d] — must fix before closing." % [
				cards_in_play, Global.MIN_DECK_SIZE, Global.MAX_DECK_SIZE,
			])
			start_shake_deck_manager()
	else:
		deck_manager.visible = true

func _on_deck_area_2d_mouse_entered() -> void:
	card_deck.scale = Vector2(0.20, 0.20)

func _on_deck_area_2d_mouse_exited() -> void:
	card_deck.scale = Vector2(0.15, 0.15)

func start_shake_deck_manager(duration: float = 0.5, strength: float = 10.0) -> void:
	shake_duration = duration
	shake_strength = strength
	shaking = true
	deck_manager_position = deck_manager.position
