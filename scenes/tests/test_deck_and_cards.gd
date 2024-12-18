extends Area2D

@onready var round_holding = get_node("HandCollisionShape2D")
@onready var card_one = get_node("CardOne")
@onready var card_two = get_node("CardTwo")
@onready var card_three = get_node("CardThree")

# A little math for documentation.
# you have a semi circle. I have three cards. Take 180 / 3
# Those are the positions i want my card
#
# x = r * cos(theta)
# y = r * sin(theta)
# angle = deg_to_rad(theta)
# 
# so do this later

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
