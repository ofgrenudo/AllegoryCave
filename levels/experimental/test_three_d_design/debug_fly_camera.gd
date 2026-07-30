extends Camera3D

## Simple free-fly debug camera for previewing the test dungeon.
## Move: WASD, Space (up), Ctrl (down), Shift (sprint).
## Look: move the mouse (captured by default). Esc releases the mouse,
## left-click re-captures it.

@export var move_speed: float = 5.0
@export var sprint_multiplier: float = 3.0
@export var mouse_sensitivity: float = 0.15

var _mouse_captured: bool = true
var _yaw: float = 0.0
var _pitch: float = 0.0

func _ready() -> void:
	_yaw = rotation_degrees.y
	_pitch = rotation_degrees.x
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not _mouse_captured:
			_mouse_captured = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and _mouse_captured:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch = clamp(_pitch, -89.0, 89.0)
		rotation_degrees = Vector3(_pitch, _yaw, 0.0)

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_mouse_captured = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	var dir := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_W):
		dir -= transform.basis.z
	if Input.is_physical_key_pressed(KEY_S):
		dir += transform.basis.z
	if Input.is_physical_key_pressed(KEY_A):
		dir -= transform.basis.x
	if Input.is_physical_key_pressed(KEY_D):
		dir += transform.basis.x
	if Input.is_physical_key_pressed(KEY_SPACE):
		dir += Vector3.UP
	if Input.is_physical_key_pressed(KEY_CTRL):
		dir -= Vector3.UP

	if dir.length() > 0.0:
		dir = dir.normalized()
		var speed := move_speed
		if Input.is_physical_key_pressed(KEY_SHIFT):
			speed *= sprint_multiplier
		position += dir * speed * delta
