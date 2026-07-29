extends Sprite2D

## Enemy — driven entirely by an EnemyData resource.
##
## On _ready(), picks a random variant from Scenes/Combat/Enemies/*.tres,
## applies the sprite/tint/scale, and runs its special-move pattern each turn.
##
## To add a new enemy: drop a new .tres file in Scenes/Combat/Enemies/. No
## code changes needed. The scan below picks it up automatically.

signal health_changed(new_hp: int, max_hp: int)
signal variant_ready(display_name: String, max_hp: int)

const ENEMY_DATA_DIR := "res://Scenes/Combat/Enemies/"

# --- Runtime state -----------------------------------------------------------
var data: EnemyData
var display_name: String = "Enemy"
var health: int = 100
var max_hp: int = 100
var atk_min: int = 8
var atk_max: int = 14
var resistances: Dictionary = {}
var special_pattern: String = ""

# --- Special-move bookkeeping ------------------------------------------------
var turn_counter: int = 0
var armor_active: bool = false           # armor_up: halves next incoming damage
var next_bonus_damage: int = 0           # corrode: adds to next attack

# --- Shake / Wobble ----------------------------------------------------------
var is_shaking := false
var wobble_intensity := 5
var shake_duration := 0.3
var shake_timer := 0.0
@onready var starting_position := position

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_pick_variant()
	_apply_variant()

# ============================================================================
# Variant selection & application
# ============================================================================
func _pick_variant() -> void:
	var pool := _scan_enemy_pool()
	if pool.is_empty():
		push_error("Enemy: no EnemyData resources found in %s" % ENEMY_DATA_DIR)
		return

	# Simple difficulty gate: filter out anything with max_hp > threshold based
	# on how many rooms you've cleared. Slime early, Elder Cube late.
	var difficulty_cap: int = 55 + (Global.rooms_visited * 10)
	var eligible: Array = pool.filter(func(d: EnemyData): return d.max_hp <= difficulty_cap)
	if eligible.is_empty():
		eligible = pool  # fall back to full pool if we filtered everything out

	data = eligible[rng.randi_range(0, eligible.size() - 1)]

func _scan_enemy_pool() -> Array:
	var out: Array = []
	var dir := DirAccess.open(ENEMY_DATA_DIR)
	if dir == null:
		return out
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".res")):
			var res = load(ENEMY_DATA_DIR + file_name)
			if res is EnemyData:
				out.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()
	return out

func _apply_variant() -> void:
	if data == null:
		return
	display_name  = data.display_name
	max_hp        = data.max_hp
	health        = max_hp
	atk_min       = data.atk_min
	atk_max       = data.atk_max
	resistances   = data.resistances.duplicate()
	special_pattern = data.special_pattern

	if data.texture != null:
		texture = data.texture
	scale     = data.sprite_scale
	modulate  = data.modulate
	starting_position = position

	print("[Enemy] %s | HP=%d | ATK=%d-%d | special=%s" % [
		display_name, max_hp, atk_min, atk_max,
		"(none)" if special_pattern == "" else special_pattern,
	])
	if data.flavor != "":
		print("        \"%s\"" % data.flavor)
	# Announce to any UI listeners.
	emit_signal("variant_ready", display_name, max_hp)
	emit_signal("health_changed", health, max_hp)

# ============================================================================
# Damage in
# ============================================================================
func apply_damage(damage_type: String, damage_value: int) -> int:
	## Returns the actual damage dealt (after resistance & armor).
	if damage_type == "Deck":
		print("Skipped Turn")
		return 0

	var mult: float = resistances.get(damage_type, 1.0)
	if armor_active:
		mult *= 0.5
		armor_active = false  # armor is a one-shot buff, consumed on next hit
		print("[%s] Armor absorbs half the blow!" % display_name)

	var final_damage := int(round(damage_value * mult))

	if final_damage > 0:
		health = max(0, health - final_damage)
		print("[%s] took %d %s damage (x%.2f). HP -> %d/%d" % [
			display_name, final_damage, damage_type, mult, health, max_hp,
		])
		start_shake_and_wobble()
		emit_signal("health_changed", health, max_hp)
	elif mult == 0.0:
		print("[%s] is IMMUNE to %s!" % [display_name, damage_type])
	else:
		print("[%s] shrugs off the %s hit." % [display_name, damage_type])

	return final_damage

# ============================================================================
# Attack out — combat.gd calls roll_attack() each enemy turn
# ============================================================================
func roll_attack() -> int:
	turn_counter += 1
	var base := rng.randi_range(atk_min, atk_max)
	var dmg := base + next_bonus_damage
	next_bonus_damage = 0

	match special_pattern:
		"double_hit":
			# Every 3rd turn, hit twice
			if turn_counter % 3 == 0:
				var second := rng.randi_range(atk_min, atk_max)
				dmg += second
				print("[%s] winds up — DOUBLE HIT for %d!" % [display_name, dmg])
			else:
				print("[%s] attacks for %d." % [display_name, dmg])

		"regen":
			# Heal at the end of the enemy's turn (unless it just died)
			if health > 0:
				var heal := 8
				var before := health
				health = min(max_hp, health + heal)
				if health > before:
					print("[%s] regenerates %d hp (%d/%d)." % [
						display_name, health - before, health, max_hp,
					])
					emit_signal("health_changed", health, max_hp)
			print("[%s] attacks for %d." % [display_name, dmg])

		"armor_up":
			# Every 3rd turn, brace for the next incoming blow
			if turn_counter % 3 == 0:
				armor_active = true
				dmg = int(dmg * 0.5)  # sacrifices offense to brace
				print("[%s] hardens its shell! Weak attack (%d), but next hit is halved." % [
					display_name, dmg,
				])
			else:
				print("[%s] attacks for %d." % [display_name, dmg])

		"life_drain":
			# 25% chance to steal life equal to half the damage dealt
			if rng.randf() < 0.25 and dmg > 0:
				var stolen: int = int(ceil(dmg * 0.5))
				var before := health
				health = min(max_hp, health + stolen)
				print("[%s] drains life! Attacks for %d, heals %d (%d/%d)." % [
					display_name, dmg, health - before, health, max_hp,
				])
				emit_signal("health_changed", health, max_hp)
			else:
				print("[%s] attacks for %d." % [display_name, dmg])

		"crit":
			# 20% chance to double the attack roll
			if rng.randf() < 0.20:
				dmg *= 2
				print("[%s] CRITS for %d!" % [display_name, dmg])
			else:
				print("[%s] attacks for %d." % [display_name, dmg])

		"corrode":
			# Applies a debuff — the NEXT attack will add +5 damage
			next_bonus_damage = 5
			print("[%s] corrodes your armor. Next attack will hit for +5." % display_name)
			print("[%s] attacks for %d." % [display_name, dmg])

		_:
			print("[%s] attacks for %d." % [display_name, dmg])

	return dmg

# ============================================================================
# Accessors
# ============================================================================
func get_health() -> int:
	return health

func get_display_name() -> String:
	return display_name

# ============================================================================
# Shake / Wobble
# ============================================================================
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

func start_shake_and_wobble() -> void:
	is_shaking = true
	shake_timer = 0.0
	set_process(true)

func apply_shake_and_wobble() -> void:
	rotation = deg_to_rad(randf_range(-wobble_intensity, wobble_intensity))
