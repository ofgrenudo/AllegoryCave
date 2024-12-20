extends Area2D

@onready var round_holding = get_node("HandCollisionShape2D")
@onready var card_one = get_node("HandCollisionShape2D/CardOne")
@onready var card_two = get_node("HandCollisionShape2D/CardTwo")
@onready var card_three = get_node("HandCollisionShape2D/CardThree")
@onready var hand_collission_shape = get_node("HandCollisionShape2D")
var card_positions
var card_one_position
var card_two_position
var card_three_position

## A little math for documentation.
## you have a semi circle. I have three cards. Take 180 / 3
## Those are the positions i want my card
##
## x = r * cos(theta)
## y = r * sin(theta)
## angle = deg_to_rad(theta)
## 
func order_in_semi_circle(number_of_items: int, radius: float, center=Vector2.ZERO) -> Array:
	var output = []
	var angle_increment = PI / (number_of_items - 1) # Semi-circle angle increment
	
	for i in range(number_of_items):
		# Calculate the angle for each item, from -PI (left edge) to 0 (right edge)
		var target_angle = -PI + i * angle_increment
		
		# Use trigonometry to calculate x and y positions
		var x = radius * cos(target_angle) + center.x
		var y = radius * sin(target_angle) + center.y
		
		# Add the card position
		output.append(Vector3(x, y, target_angle))
	
	return output

## NOTE Unused...
func order_in_circle(number_of_items: int, radius: float, center=Vector2.ZERO, start_offset=0.0) -> Array:
	var output = []
	var offset = 2.0 * PI / abs(number_of_items) # Confirms N is non zero
	
	for item in number_of_items:
		var new_position = radius * Vector2.from_angle(item * offset + start_offset)
		output.push_front(new_position + center)
	
	return output
		#polar2cartesian(radius, item * offset + start_offset)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_positions = order_in_semi_circle(3, hand_collission_shape.shape.radius, Vector2.ZERO)
	card_one_position = Vector2(card_positions[0][0], card_positions[0][1])
	card_two_position = Vector2(card_positions[1][0], card_positions[1][1])
	card_three_position = Vector2(card_positions[2][0], card_positions[2][1])

	#print(card_positions)
	card_one.position = card_one_position
	card_one.rotation = deg_to_rad(card_positions[0][2])
	
	card_two.position = card_two_position
	card_two.rotation = deg_to_rad(card_positions[1][2])
	
	card_three.position = card_three_position
	card_three.rotation = deg_to_rad(card_positions[2][2])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_one.is_dragging == false and card_one.position != card_one_position:
		# TODO Check if Card is Colliding with Object
		print(card_one.position)
		card_one.position = card_one_position
	if card_two.is_dragging == false and card_two.position != card_two_position:
		# TODO Check if Card is Colliding with Object
		print(card_two.position)
		card_two.position = card_two_position
	if card_three.is_dragging == false and card_three.position != card_three_position:	
		# TODO Check if Card is Colliding with Object
		print(card_three.position)
		card_three.position = card_three_position
