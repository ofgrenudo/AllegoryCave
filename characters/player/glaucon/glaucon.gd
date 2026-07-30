extends Node2D

# What is is a base attribute? 
# Base attributes are essentially your skill points 
# for that particular character.
# 
# There is typically the following base states:
# - health
# - attack
# - defense
# - evasion

# Health
var glaucon_base_health = 85
var glaucon_base_health_bonus = 0

# Attack
var glaucon_base_attack = 10
var glaucon_base_attack_modifier = 15
var glaucon_base_attack_bonus = 0

# Defense
var glaucon_base_defence = 10
var glaucon_base_defence_modifier = 15
var glaucon_base_defence_bonus = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
