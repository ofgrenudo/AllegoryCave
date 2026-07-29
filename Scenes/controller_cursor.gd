extends Node

## ControllerCursor — autoload
##
## Makes the game fully playable with a gamepad by:
##   1. Moving the OS mouse cursor with the left stick + D-Pad
##      (uses cursor_left / cursor_right / cursor_up / cursor_down actions)
##   2. Synthesizing a mouse click at the cursor position when the "select"
##      action is triggered by a joypad button.
##
## Because clicks are synthesized as real mouse events, every existing
## Area2D input_event handler and every Button in the project keeps working
## without any per-scene wiring changes.

const CURSOR_SPEED: float = 1400.0   # pixels per second at full stick deflection
const CLICK_COOLDOWN: float = 0.15   # debounce for held A button

var _cooldown: float = 0.0
var _joypad_recently_used: bool = false

func _ready() -> void:
	# We want to run even when the tree is paused so pause menus keep working.
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta

	# Read directional strength (works for stick axes AND d-pad buttons because
	# both are bound to the same actions in project.godot).
	var dir := Vector2(
		Input.get_action_strength("cursor_right") - Input.get_action_strength("cursor_left"),
		Input.get_action_strength("cursor_down")  - Input.get_action_strength("cursor_up"),
	)

	if dir.length_squared() > 0.0:
		_joypad_recently_used = true
		var viewport := get_viewport()
		if viewport == null:
			return
		var current: Vector2 = viewport.get_mouse_position()
		var next: Vector2 = current + dir * CURSOR_SPEED * delta

		# Clamp to the visible viewport rectangle.
		var size: Vector2 = viewport.get_visible_rect().size
		next.x = clamp(next.x, 0.0, size.x - 1.0)
		next.y = clamp(next.y, 0.0, size.y - 1.0)

		Input.warp_mouse(next)

func _unhandled_input(event: InputEvent) -> void:
	# Only synthesize a click for JOYPAD "select" presses. Real mouse and
	# keyboard "select" events already work on their own.
	if not (event is InputEventJoypadButton):
		return
	if not event.is_action_pressed("select"):
		return
	if _cooldown > 0.0:
		return
	_cooldown = CLICK_COOLDOWN
	_synth_mouse_click()

func _synth_mouse_click() -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var pos: Vector2 = viewport.get_mouse_position()

	# Fire a press...
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = pos
	press.global_position = pos
	press.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(press)

	# ...and a release, so click-once handlers don't get stuck.
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = pos
	release.global_position = pos
	release.button_mask = 0
	Input.parse_input_event(release)
