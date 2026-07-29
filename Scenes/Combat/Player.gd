extends Node2D

## Player — no visual sprite (the health is shown via the UI HealthBar).
## Persists HP across scene changes via Global.player_health.

signal health_changed(new_hp: int, max_hp: int)

var max_hp: int = Global.PLAYER_MAX_HEALTH
var health: int = Global.PLAYER_MAX_HEALTH

# Set by playing a Defend card — absorbs the next incoming hit, then clears.
var block_active := false

# --- Shake Vars (for screen-style feedback on damage) ---
var is_shaking := false
var wobble_intensity := 9
var shake_duration := 0.3
var shake_timer := 0.0
@onready var starting_position := position

func _ready() -> void:
	# Restore health from the global state so combat scenes remember damage.
	health = Global.player_health
	emit_signal("health_changed", health, max_hp)

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
	if block_active:
		block_active = false
		print("Player blocks the attack!")
		emit_signal("health_changed", health, max_hp)
		return
	if damage_value > 0:
		health = max(0, health - damage_value)
		Global.player_health = health  # persist across scenes
		print("Player Health -> ", health)
		start_shake_and_wobble()
	emit_signal("health_changed", health, max_hp)

func add_block() -> void:
	## Called when a Defend card is played — absorbs the next hit entirely.
	block_active = true

func heal(amount: int) -> void:
	if amount > 0:
		health = min(max_hp, health + amount)
		Global.player_health = health
		emit_signal("health_changed", health, max_hp)

func get_health() -> int:
	return health

func get_max_health() -> int:
	return max_hp

func start_shake_and_wobble() -> void:
	is_shaking = true
	shake_timer = 0.0
	set_process(true)

func apply_shake_and_wobble() -> void:
	rotation = deg_to_rad(randf_range(-wobble_intensity, wobble_intensity))
