extends Sprite2D

## Enemy — now supports variants with different HP, damage, and elemental
## resistances/weaknesses. Variant is chosen randomly on _ready().

# --- Variant data -------------------------------------------------------------
# Each variant has: hp, attack (min, max), and a resistance table where
#   > 1.0 = weak to (takes more damage)
#   < 1.0 = resistant to (takes less)
#   0.0  = immune
const VARIANTS := {
	"Blob": {
		"hp": 90,
		"atk": [8, 14],
		"res": {"Fire": 1.5, "Ice": 0.5, "Acid": 0.25},
	},
	"Wisp": {
		"hp": 60,
		"atk": [10, 18],
		"res": {"Light": 0.25, "Lightning": 1.5, "Fire": 0.75},
	},
	"Golem": {
		"hp": 140,
		"atk": [12, 20],
		"res": {"Lightning": 1.5, "Acid": 1.25, "Fire": 0.5, "Ice": 0.75},
	},
	"Shade": {
		"hp": 80,
		"atk": [14, 22],
		"res": {"Light": 2.0, "Lightning": 1.25, "Ice": 0.5},
	},
}

var variant_name: String = "Blob"
var health: int = 100
var atk_min: int = 10
var atk_max: int = 20
var resistances: Dictionary = {}

# --- Shake / Wobble ----------------------------------------------------------
var is_shaking := false
var shake_intensity := 1
var wobble_intensity := 5
var shake_duration := 0.3
var shake_timer := 0.0
@onready var starting_position := position

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_pick_variant()

func _pick_variant() -> void:
	var keys := VARIANTS.keys()
	variant_name = keys[rng.randi_range(0, keys.size() - 1)]
	var v: Dictionary = VARIANTS[variant_name]
	health = v["hp"]
	atk_min = v["atk"][0]
	atk_max = v["atk"][1]
	resistances = v["res"]
	print("Enemy variant: ", variant_name, " HP=", health, " ATK=", atk_min, "-", atk_max)

func _process(delta: float) -> void:
	if is_shaking:
		shake_timer += delta
		if shake_timer > shake_duration:
			is_shaking = false
			set_position(starting_position)
			rotation = 0
			set_process(false)
		else:
			apply_shake_and_wobble()

func apply_damage(damage_type: String, damage_value: int) -> int:
	## Returns the actual damage dealt (after resistance multipliers).
	if damage_type == "Deck":
		print("Skipped Turn")
		return 0

	var mult: float = resistances.get(damage_type, 1.0)
	var final_damage := int(round(damage_value * mult))

	if final_damage > 0:
		health -= final_damage
		print("Enemy (%s) took %d %s damage (x%.2f). HP -> %d" % [
			variant_name, final_damage, damage_type, mult, health
		])
		start_shake_and_wobble()
	else:
		print("Enemy (%s) is immune to %s!" % [variant_name, damage_type])

	return final_damage

func roll_attack() -> int:
	return rng.randi_range(atk_min, atk_max)

func get_health() -> int:
	return health

func start_shake_and_wobble() -> void:
	is_shaking = true
	shake_timer = 0.0
	set_process(true)

func apply_shake_and_wobble() -> void:
	rotation = deg_to_rad(randf_range(-wobble_intensity, wobble_intensity))
