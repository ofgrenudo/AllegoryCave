extends Node

## ControllerCursor — autoload
##
## Moves the OS mouse cursor with the left stick + D-Pad and synthesizes a
## mouse click when the "select" action fires from a joypad button.
##
## In Combat and Navigation the purpose-built card_left/card_right/nav_left/
## nav_right actions take over, so we disable cursor movement in those scenes
## to avoid the stick controlling both things at once.

const CURSOR_SPEED: float = 1400.0
const CLICK_COOLDOWN: float = 0.15

# Scenes where we suppress cursor movement (the scene's own input handles it).
const SUPPRESS_CURSOR_SCENES := [
	"res://Scenes/Combat/Combat.tscn",
	"res://Scenes/Navigation/Navigation.tscn",
]

var _cooldown: float = 0.0
var _suppress_cursor: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.connect("ready", _on_scene_changed)
	# Also check on the first frame.
	call_deferred("_on_scene_changed")

func _on_scene_changed() -> void:
	var scene = get_tree().current_scene
	if scene == null:
		_suppress_cursor = false
		return
	var path: String = scene.scene_file_path
	_suppress_cursor = SUPPRESS_CURSOR_SCENES.has(path)

func _process(delta: float) -> void:
	# Re-check every frame cheaply (current_scene changes after scene switch).
	var scene = get_tree().current_scene
	if scene:
		_suppress_cursor = SUPPRESS_CURSOR_SCENES.has(scene.scene_file_path)

	if _cooldown > 0.0:
		_cooldown -= delta

	if _suppress_cursor:
		return

	var dir := Vector2(
		Input.get_action_strength("cursor_right") - Input.get_action_strength("cursor_left"),
		Input.get_action_strength("cursor_down")  - Input.get_action_strength("cursor_up"),
	)

	if dir.length_squared() > 0.0:
		var viewport := get_viewport()
		if viewport == null:
			return
		var current: Vector2 = viewport.get_mouse_position()
		var next: Vector2 = current + dir * CURSOR_SPEED * delta
		var size: Vector2 = viewport.get_visible_rect().size
		next.x = clamp(next.x, 0.0, size.x - 1.0)
		next.y = clamp(next.y, 0.0, size.y - 1.0)
		Input.warp_mouse(next)

func _unhandled_input(event: InputEvent) -> void:
	if _suppress_cursor:
		return
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

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = pos
	press.global_position = pos
	press.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(press)

	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = pos
	release.global_position = pos
	release.button_mask = 0
	Input.parse_input_event(release)
