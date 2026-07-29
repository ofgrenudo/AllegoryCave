extends Sprite2D

## Hand — draws N unique cards from the player's enabled deck at scene start.
## Cleaned up: getters no longer mutate state; card selection is polled cleanly
## by combat.gd.

# --- Hover flags (used by hover scale effect) ---
var card_deck_hovered := false

# --- Selection flags ---
var card_deck_selected := false
var card_selected      := false

# --- Card node refs ---
@onready var card_one   = null
@onready var card_two   = null
@onready var card_three = null
@onready var card_deck  := get_node("Deck")

# Full pool of scenes the player has unlocked.
var all_playable_cards: Array = []

var rng := RandomNumberGenerator.new()

# Map card_name -> scene path
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

const CARD_POSITIONS := [
	Vector2(-319, 920),
	Vector2(-109, 920),
	Vector2( 100, 920),
]
const CARD_ROTATIONS := [-12.0, 0.0, 12.0]  # degrees

func _ready() -> void:
	rng.randomize()
	_register_playable_cards()
	_draw_and_place_cards()

func _register_playable_cards() -> void:
	for card_name in Global.card_states.keys():
		if Global.card_states[card_name] and CARD_SCENE_MAP.has(card_name):
			all_playable_cards.append(CARD_SCENE_MAP[card_name])

func _draw_and_place_cards() -> void:
	# Draw 3 UNIQUE indexes if we have >= 3 cards; otherwise fall back to
	# sampling with replacement (rare corner case if deck has <3 cards).
	var draw_count := 3
	var indices: Array = []

	if all_playable_cards.size() == 0:
		push_error("Hand: player has NO cards enabled. Cannot draw.")
		return

	if all_playable_cards.size() >= draw_count:
		var pool := range(all_playable_cards.size())
		pool.shuffle()
		indices = pool.slice(0, draw_count)
	else:
		# Fallback (shouldn't happen thanks to MIN_DECK_SIZE, but be safe).
		while indices.size() < draw_count:
			indices.append(rng.randi_range(0, all_playable_cards.size() - 1))

	var slots := [null, null, null]
	for i in draw_count:
		var path: String = all_playable_cards[indices[i]]
		var scn = load(path)
		if scn is PackedScene:
			var inst = scn.instantiate()
			inst.position = CARD_POSITIONS[i]
			inst.rotation = deg_to_rad(CARD_ROTATIONS[i])
			add_child(inst)
			slots[i] = inst
		else:
			push_error("Hand: %s is not a PackedScene." % path)

	card_one   = slots[0]
	card_two   = slots[1]
	card_three = slots[2]

# ============================= Public API =====================================
# NOTE: These getters are now PURE — they DO NOT mutate card_selected.
# combat.gd polls them each frame; the previous impl caused a feedback loop.

func get_card_selected() -> bool:
	# True if the player has clicked ANY card this "turn".
	if card_deck_selected:
		return true
	if card_one and card_one.selected:
		return true
	if card_two and card_two.selected:
		return true
	if card_three and card_three.selected:
		return true
	return false

func toggle_card_selected() -> void:
	# Reset selection state after combat.gd has consumed the choice.
	if card_one:   card_one.selected = false
	if card_two:   card_two.selected = false
	if card_three: card_three.selected = false
	card_deck_selected = false
	card_selected = false

# ------------------------- Card One ------------------------------------------
func get_card_one_selected() -> bool: return card_one != null and card_one.selected
func get_card_one_type():             return card_one.card_type if card_one else "None"
func get_card_one_damage() -> int:    return card_one.card_damage if card_one else 0

# ------------------------- Card Two ------------------------------------------
func get_card_two_selected() -> bool: return card_two != null and card_two.selected
func get_card_two_type():             return card_two.card_type if card_two else "None"
func get_card_two_damage() -> int:    return card_two.card_damage if card_two else 0

# ------------------------- Card Three ----------------------------------------
func get_card_three_selected() -> bool: return card_three != null and card_three.selected
func get_card_three_type():             return card_three.card_type if card_three else "None"
func get_card_three_damage() -> int:    return card_three.card_damage if card_three else 0

# ------------------------- Deck ----------------------------------------------
func get_card_deck_selected() -> bool: return card_deck_selected

# ============================= Signals ========================================
func _on_deck_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		card_deck_selected = true

func _on_deck_area_2d_mouse_entered() -> void:
	card_deck_hovered = true
	card_deck.scale = Vector2(0.40, 0.40)

func _on_deck_area_2d_mouse_exited() -> void:
	card_deck_hovered = false
	card_deck.scale = Vector2(0.35, 0.35)
