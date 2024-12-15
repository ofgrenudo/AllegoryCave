extends Sprite2D

var total_health = 100
var health = 100

var heart_one_comparison = 0 * total_health
var heart_two_comparison = 0.66 * total_health
var heart_three_comparison = 1.0 * total_health


## Shake Vars
var is_shaking = false  ## To prevent multiple shake calls
var shake_intensity = 0  ## How far the object moves when shaking
var wobble_intensity = 9  ## How much the object rotates
var shake_duration = 0.3  ## Duration of the effect
var shake_timer = 0.0  ## Internal timer
@onready var starting_position = position ## Hard Coded Value.... Cant figure out how to get these in script

@onready var heart_one = get_node("HeartOne")
@onready var heart_two = get_node("HeartTwo")
@onready var heart_three = get_node("HeartThree")

@onready var damage_timer := $DamageTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_shaking:
		shake_timer += delta
		if shake_timer > shake_duration:
			is_shaking = false
			set_position(starting_position)  # Reset position to original
			rotation = 0  # Reset rotation
			set_process(false)  # Disable processing
		else:
			apply_shake_and_wobble()

func apply_damage(damage_value: int):
	if (damage_value > 0):
		health = health - damage_value
		print("Player Health -> ", health)
		start_shake_and_wobble()

	#print(health, "<=", heart_three_comparison)
	#print(health, "<=", heart_two_comparison)
	#print(health, "<=", heart_one_comparison)

	# Check hearts in order: heart three, heart two, heart one
	if health <= heart_three_comparison:
		heart_three.visible = false  # Highest threshold
	
	if health <= heart_two_comparison:
		heart_two.visible = false  # Middle threshold
		heart_three.visible = false

	if health <= heart_one_comparison:
		heart_one.visible = false  # Lowest threshold
		heart_two.visible = false
		heart_three.visible = false
	

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
	# var shake_x = randf_range(-shake_intensity, shake_intensity)
	# var shake_y = randf_range(-shake_intensity, shake_intensity)
	# position = Vector2(shake_x, shake_y)

	# Random wobble rotation
	rotation = deg_to_rad(randf_range(-wobble_intensity, wobble_intensity))
