extends Control
class_name HealthBar

## Reusable animated health bar.
##
## Shows a colored fill for current HP, a trailing white bar that lingers
## after damage (Persona/JRPG-style), and a "NAME  hp/max" label overlay.
## Colors shift green -> yellow -> red as HP drops.

@onready var _bg:          ColorRect = $Plate
@onready var _fill:        ColorRect = $Plate/Fill
@onready var _trail:       ColorRect = $Plate/DamageTrail
@onready var _name_label:  Label     = $Plate/NameLabel
@onready var _hp_label:    Label     = $Plate/HpLabel

const TRAIL_DELAY := 0.35   # how long the white trail lingers
const FILL_TIME   := 0.25   # how long the main fill takes to catch up
const TRAIL_TIME  := 0.40   # how long the trail takes to catch up (after delay)

const COLOR_HIGH := Color(0.35, 0.85, 0.40, 1)   # green
const COLOR_MID  := Color(0.98, 0.80, 0.20, 1)   # gold
const COLOR_LOW  := Color(0.92, 0.22, 0.24, 1)   # red

var _max_hp: int = 100
var _current_hp: int = 100
var _last_shown_hp: int = 100     # last value we tweened the main fill to
var _tween_fill: Tween
var _tween_trail: Tween

func setup(display_name: String, max_hp: int, current_hp: int = -1) -> void:
	## Call once when combat starts (or whenever the entity changes).
	if current_hp < 0:
		current_hp = max_hp
	_max_hp = max(1, max_hp)
	_current_hp = clamp(current_hp, 0, _max_hp)
	_last_shown_hp = _current_hp
	if _name_label:
		_name_label.text = display_name
	_apply_immediate()

func set_hp(new_hp: int) -> void:
	## Animate to the new HP. Call whenever damage is dealt or healing applied.
	new_hp = clamp(new_hp, 0, _max_hp)
	if new_hp == _current_hp:
		return
	var is_damage := new_hp < _current_hp
	_current_hp = new_hp
	_animate_to(_current_hp, is_damage)

func await_settled() -> void:
	## Yields until the currently-running fill tween finishes. combat.gd calls
	## this so the "slower combat" flow can wait for the healthbar to visibly
	## drain before the next beat.
	##
	## IMPORTANT: We only await if the tween is still RUNNING. Awaiting
	## .finished on a tween that already completed will hang forever, because
	## the signal already fired and Godot signals don't buffer.
	if _tween_fill and _tween_fill.is_valid() and _tween_fill.is_running():
		await _tween_fill.finished

# ------------------------------------------------------------------------
func _apply_immediate() -> void:
	if _fill == null:
		return
	var pct := float(_current_hp) / float(_max_hp)
	_fill.anchor_right = pct
	_trail.anchor_right = pct
	_fill.color = _hp_color(pct)
	_last_shown_hp = _current_hp
	_update_label()

func _animate_to(target_hp: int, is_damage: bool) -> void:
	var pct := float(target_hp) / float(_max_hp)

	# Kill any in-flight tweens so we don't fight ourselves on rapid hits.
	if _tween_fill and _tween_fill.is_valid():
		_tween_fill.kill()
	if _tween_trail and _tween_trail.is_valid():
		_tween_trail.kill()

	# Main colored fill snaps quickly.
	_tween_fill = create_tween().set_parallel(true)
	_tween_fill.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween_fill.tween_property(_fill, "anchor_right", pct, FILL_TIME)
	_tween_fill.tween_property(_fill, "color", _hp_color(pct), FILL_TIME)

	# The trail follows.
	if is_damage:
		# On damage: trail hangs where the old HP was, then catches up.
		_tween_trail = create_tween()
		_tween_trail.tween_interval(TRAIL_DELAY)
		_tween_trail.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		_tween_trail.tween_property(_trail, "anchor_right", pct, TRAIL_TIME)
	else:
		# On heal: trail leads (already ahead), main fill catches up to it.
		# Snap the trail forward now so the main bar has something to grow into.
		_trail.anchor_right = pct

	# Number label ticks up/down alongside the main fill.
	var counter := create_tween()
	counter.tween_method(_tick_label, _last_shown_hp, target_hp, FILL_TIME)
	_last_shown_hp = target_hp

func _tick_label(v: float) -> void:
	_current_hp = int(round(v))
	_update_label()

func _update_label() -> void:
	if _hp_label:
		_hp_label.text = "%d / %d" % [_current_hp, _max_hp]

func _hp_color(pct: float) -> Color:
	if pct > 0.5:
		# 1.0 -> green, 0.5 -> gold
		var t := (1.0 - pct) / 0.5
		return COLOR_HIGH.lerp(COLOR_MID, t)
	# 0.5 -> gold, 0.0 -> red
	var t2 := (0.5 - pct) / 0.5
	return COLOR_MID.lerp(COLOR_LOW, clamp(t2, 0.0, 1.0))
