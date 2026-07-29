extends Sprite2D

## Hand — full deckbuilder loop.
##
## Piles: draw_pile, hand, discard_pile — all lists of card SCENE PATHS.
## On turn start: draw HAND_SIZE cards. If the draw pile runs out mid-draw,
## the discard pile is shuffled into the draw pile and drawing continues.
##
## Clicking a card in the hand plays it (emits card_played) and moves it
## to the discard pile. End Turn (button in the UI) discards the rest of
## the hand and draws a fresh HAND_SIZE.

signal card_played(card_type: String, card_damage: int)
signal piles_changed(draw_count: int, hand_count: int, discard_count: int)

const HAND_SIZE := 5

# Card scene path map (kept the same as before)
const CARD_SCENE_MAP := {
	"LightningOne": "res://Scenes/Cards/lightning_one.tscn",
	"LightningTwo": "res://Scenes/Cards/lightning_two.tscn",
	"FireOne":      "res://Scenes/Cards/fire_one.tscn",
	"IceOne":       "res://Scenes/Cards/ice_one.tscn",
	"AcidOne":      "res://Scenes/Cards/acid_one.tscn",
	"AcidTwo":      "res://Scenes/Cards/acid_two.tscn",
	"LightOne":     "res://Scenes/Cards/light_one.tscn",
	"LightTwo":     "res://Scenes/Cards/light_two.tscn",
	"IceTwo":       "res://Scenes/Cards/ice_two.tscn",
	"SevenDiamond": "res://Scenes/Cards/seven_diamonds.tscn",
	"ThreeHearts":  "res://Scenes/Cards/three_hearts.tscn",
	"EightClubs":   "res://Scenes/Cards/eight_clubs.tscn",
	"FiveDiamond":  "res://Scenes/Cards/five_diamonds.tscn",
	"AceDiamond":   "res://Scenes/Cards/ace_diamonds.tscn",
}

# Fan layout for the hand
const FAN_Y := 920.0
const FAN_X_SPAN := 900.0    # total horizontal spread for the whole fan
const FAN_ROT_SPAN := 24.0   # total rotation spread in degrees (edge cards)

# The three piles hold scene PATHS (strings). Only the "hand" gets instantiated.
var draw_pile: Array = []
var discard_pile: Array = []
var hand_paths: Array = []            # scene paths currently in hand
var hand_nodes: Array = []            # matching Card node instances

# Locking prevents the player from clicking a second card while the first
# is still resolving.
var input_locked := true

@onready var card_deck := get_node("Deck")

var rng := RandomNumberGenerator.new()

# ============================================================================
# Setup
# ============================================================================
func _ready() -> void:
	rng.randomize()
	_build_starting_draw_pile()
	# Combat.gd calls start_turn() once it's finished wiring signals.

func _build_starting_draw_pile() -> void:
	draw_pile.clear()
	discard_pile.clear()
	for card_name in Global.card_states.keys():
		if Global.card_states[card_name] and CARD_SCENE_MAP.has(card_name):
			draw_pile.append(CARD_SCENE_MAP[card_name])
	draw_pile.shuffle()
	if draw_pile.is_empty():
		push_error("Hand: player has no enabled cards. Deck is empty.")

# ============================================================================
# Turn hooks (called by combat.gd)
# ============================================================================
func start_turn() -> void:
	_draw_up_to(HAND_SIZE)
	input_locked = false
	_emit_pile_state()

func end_turn() -> void:
	## Discard whatever is left in the hand. Combat.gd calls this from its
	## End Turn button handler BEFORE swapping to the enemy turn.
	input_locked = true
	for i in range(hand_paths.size()):
		discard_pile.append(hand_paths[i])
	_clear_hand_nodes()
	hand_paths.clear()
	_emit_pile_state()

# ============================================================================
# Draw / reshuffle
# ============================================================================
func _draw_up_to(target: int) -> void:
	while hand_paths.size() < target:
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break  # ran out entirely — small deck, hand is what it is
			_reshuffle_discard_into_draw()
		var path: String = draw_pile.pop_back()
		hand_paths.append(path)
	_layout_hand()

func _reshuffle_discard_into_draw() -> void:
	print("[Hand] Draw pile empty — shuffling %d discard into draw pile." % discard_pile.size())
	for p in discard_pile:
		draw_pile.append(p)
	discard_pile.clear()
	draw_pile.shuffle()

# ============================================================================
# Layout — instantiate hand nodes and fan them out
# ============================================================================
func _clear_hand_nodes() -> void:
	for node in hand_nodes:
		if is_instance_valid(node):
			node.queue_free()
	hand_nodes.clear()

func _layout_hand() -> void:
	_clear_hand_nodes()
	var n: int = hand_paths.size()
	if n == 0:
		return

	for i in n:
		var path: String = hand_paths[i]
		var scn = load(path)
		if not (scn is PackedScene):
			push_error("Hand: %s is not a PackedScene." % path)
			continue
		var inst = scn.instantiate()

		# Fan positioning: centered on 0, spread across FAN_X_SPAN
		var t: float = 0.0 if n == 1 else float(i) / float(n - 1)   # 0..1
		var x: float = lerp(-FAN_X_SPAN * 0.5, FAN_X_SPAN * 0.5, t)
		var rot_deg: float = lerp(-FAN_ROT_SPAN * 0.5, FAN_ROT_SPAN * 0.5, t)

		inst.position = Vector2(x, FAN_Y)
		inst.rotation = deg_to_rad(rot_deg)

		# Stamp the source path so we can move the exact card to the discard.
		inst.set_meta("scene_path", path)

		add_child(inst)
		hand_nodes.append(inst)

# ============================================================================
# Poll for a played card (each card sets .selected = true on click)
# ============================================================================
func _process(_delta: float) -> void:
	if input_locked:
		return
	for card in hand_nodes:
		if is_instance_valid(card) and card.selected:
			_play_card(card)
			break  # one at a time

func _play_card(card: Node) -> void:
	input_locked = true
	var card_type = card.card_type if "card_type" in card else "None"
	var card_damage: int = card.card_damage if "card_damage" in card else 0
	var path: String = card.get_meta("scene_path", "")

	print("[Hand] played %s (%d dmg)" % [card_type, card_damage])
	emit_signal("card_played", card_type, card_damage)

	# Move it out of the hand.
	var idx := hand_nodes.find(card)
	if idx >= 0:
		hand_nodes.remove_at(idx)
		hand_paths.remove_at(idx)
	if path != "":
		discard_pile.append(path)

	card.queue_free()
	_layout_hand()
	_emit_pile_state()

	# After the card resolves, combat.gd will unlock us or advance the turn.

func resume_input() -> void:
	## Combat.gd calls this after a card resolves, if it's still the player's
	## turn (and the hand still has cards).
	input_locked = false

func lock_input() -> void:
	input_locked = true

# ============================================================================
# Accessors
# ============================================================================
func hand_count() -> int:
	return hand_paths.size()

func draw_count() -> int:
	return draw_pile.size()

func discard_count() -> int:
	return discard_pile.size()

func _emit_pile_state() -> void:
	emit_signal("piles_changed", draw_pile.size(), hand_paths.size(), discard_pile.size())

# ============================================================================
# Deck sprite (visual only now — clicking it just gives feedback)
# ============================================================================
func _on_deck_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		print("[Hand] Draw pile: %d | Discard: %d" % [draw_pile.size(), discard_pile.size()])

func _on_deck_area_2d_mouse_entered() -> void:
	card_deck.scale = Vector2(0.40, 0.40)

func _on_deck_area_2d_mouse_exited() -> void:
	card_deck.scale = Vector2(0.35, 0.35)
