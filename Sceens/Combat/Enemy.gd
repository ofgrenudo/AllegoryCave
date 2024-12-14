extends Sprite2D

var health = 100

## Shake Vars
var is_shaking = false  ## To prevent multiple shake calls
var shake_intensity = 0  ## How far the object moves when shaking
var wobble_intensity = 5  ## How much the object rotates
var shake_duration = 0.3  ## Duration of the effect
var shake_timer = 0.0  ## Internal timer
@onready var starting_position = Vector2(2, 59) ## Hard Coded Value.... Cant figure out how to get these in script

func _ready():
	pass  # Called when the node is added to the scene

func _process(delta):
	if is_shaking:
		shake_timer += delta
		if shake_timer > shake_duration:
			is_shaking = false
			set_position(starting_position)  # Reset position to original
			rotation = 0  # Reset rotation
			set_process(false)  # Disable processing
		else:
			apply_shake_and_wobble()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if not is_shaking:
			start_shake_and_wobble()

func apply_damage(damage_type: String, damage_value: int):
	if (damage_value > 0):
		health = health - damage_value
		print("==================== ", health)
		start_shake_and_wobble()
	
	if (damage_type == "Deck"):
		print("Skipped Turn")

func get_health() -> int:
	return health

## Start Timer
func start_shake_and_wobble():
	is_shaking = true
	shake_timer = 0.0  # Reset the timer
	set_process(true)  # Enable processing

## Start Shake and Wobble
func apply_shake_and_wobble():
	# Random shake offset
	var shake_x = randf_range(-shake_intensity, shake_intensity)
	var shake_y = randf_range(-shake_intensity, shake_intensity)
	position = Vector2(shake_x, shake_y)

	# Random wobble rotation
	rotation = deg_to_rad(randf_range(-wobble_intensity, wobble_intensity))
