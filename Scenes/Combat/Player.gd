extends Sprite2D

## The player uses Global.player_health so HP persists across scene changes
## (combat -> navigation -> combat).

var total_health: int = Global.PLAYER_MAX_HEALTH
var health: int = Global.PLAYER_MAX_HEALTH

var heart_one_comparison: float = 0.33 * total_health
var heart_two_comparison: float = 0.66 * total_health
var heart_three_comparison: float = 1.0 * total_health

# --- Shake Vars ---
var is_shaking := false
var shake_intensity := 0
var wobble_intensity := 9
var shake_duration := 0.3
var shake_timer := 0.0
@onready var starting_position := position

@onready var heart_one   = get_node("HeartOne")
@onready var heart_two   = get_node("HeartTwo")
@onready var heart_three = get_node("HeartThree")

@onready var damage_timer := $DamageTimer

func _ready() -> void:
	# Restore health from the global state so combat scenes remember damage.
	health = Global.player_health
	_refresh_hearts()

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

func apply_damage(damage_value: int) -> void:
	if damage_value > 0:
		health = max(0, health - damage_value)
		Global.player_health = health  # persist across scenes
		print("Player Health -> ", health)
		start_shake_and_wobble()
	_refresh_hearts()

func _refresh_hearts() -> void:
	heart_three.visible = health > heart_two_comparison
	heart_two.visible   = health > heart_one_comparison
	heart_one.visible   = health > 0

func get_health() -> int:
	return health

func start_shake_and_wobble() -> void:
	is_shaking = true
	shake_timer = 0.0
	set_process(true)

func apply_shake_and_wobble() -> void:
	rotation = deg_to_rad(randf_range(-wobble_intensity, wobble_intensity))
