class_name Enemy extends Node

enum EnemyArt {
	BLOBBY,
	CUBE,
}

const DEFAULT_ENEMY_SKILL_LIST = [["Defend", 0],] 

@export var enemy_health = 100
@export var enemy_type = "Base"
@export var enemy_skill_list = [["Defend", 0],]
@export var enemy_art: EnemyArt = EnemyArt.BLOBBY  
@export var scale_factor: float = 0.125

@onready var loaded_art = load("res://entities/enemies/base/blobby.png")
@onready var enemy_sprite = get_node("Sprite2D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_random_enemy()
	load_enemy()
	enemy_sprite.scale = Vector2(scale_factor, scale_factor)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_health() -> int:
	return enemy_health

func get_enemy_skill_list() -> Array:
	return enemy_skill_list

func get_attack_skill() -> Array:
	var skill_list_count = enemy_skill_list.size()
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	if skill_list_count > 0:  # Ensure the list is not empty
		var selected_skill = rng.randi_range(0, skill_list_count - 1)
		return enemy_skill_list[selected_skill]  # Return the randomly selected skill
	else:  # Handle empty list
		return ["ENEMY > Skill List Is Empty", 0]


func set_health(health: int):
	enemy_health = health

func deal_damage(damage_dealt: float, multiplier: float = 1.0):
	enemy_health -= damage_dealt * multiplier

func set_random_enemy():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var enemy_art_keys = EnemyArt.keys()
	var enemy_art_size = enemy_art_keys.size()
	var selected_index = rng.randi_range(0, enemy_art_size - 1)
	
	enemy_art = EnemyArt[enemy_art_keys[selected_index]]
	
	#print("ENEMY > Index:", selected_index)
	print("ENEMY > Randomly Selected Enemy Is ", enemy_art_keys[selected_index])

func load_enemy():
	# Debug: Print the selected enemy art
	print("ENEMY > Setting Enemy Art to ", EnemyArt.keys()[enemy_art])
	
	# Start with a new copy of the default skill list to avoid mutating shared data
	enemy_skill_list = DEFAULT_ENEMY_SKILL_LIST.duplicate()
	
	match enemy_art:
		EnemyArt.BLOBBY:
			loaded_art = load("res://entities/enemies/base/blobby.png")
			enemy_skill_list.append(["Blobby Slam", 15])  # Example skill for BLOBBY
		EnemyArt.CUBE:
			loaded_art = load("res://entities/enemies/base/cube.png")
			enemy_skill_list.append(["Cubed", 2 * 2 * 2])  # Cube's unique skill
		_:
			# Handle invalid `enemy_art` with a placeholder or error
			print("ENEMY > Unknown enemy art, defaulting to BLOBBY")
			loaded_art = load("res://entities/enemies/base/blobby.png")
			enemy_skill_list.append(["Default Attack", 10])  # A generic fallback skill
	
	# Debug: Print the updated enemy skill list
	print("ENEMY > Final Enemy Skill List: ", enemy_skill_list)
	
	# Assign the loaded texture to the sprite
	enemy_sprite.texture = loaded_art
