class_name Room extends Control

## Room Types
## This class is not intended to prevent you from using any kind of specific room,
## but it is made to allow you to use any room provided at a consistent aspect ratio.
enum RoomType {
	FORWARD_LEFT,
	FORWARD_RIGHT,
	INTRO_WAKE_UP,
	LEFT,
	LEFT_OR_RIGHT_ONE,
	LEFT_OR_RIGHT_TWO,
	RIGHT,
	ROOM,
	TITLE_CARD,
}

var loaded_room

## Variables that will appear in the root nodes inspector
@export var selected_room: RoomType = RoomType.INTRO_WAKE_UP
@onready var room_image = get_node("Image")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_selected_room()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Load our selected room into the Images Texture Rect Texture
func load_selected_room():
	match selected_room:
		RoomType.FORWARD_LEFT:
			loaded_room = load("res://entities/rooms/forward_left.PNG")
		RoomType.FORWARD_RIGHT:
			loaded_room = load("res://entities/rooms/forward_right.PNG")
		RoomType.INTRO_WAKE_UP:
			loaded_room = load("res://entities/rooms/intro_wake_up.png")
		RoomType.LEFT:
			loaded_room = load("res://entities/rooms/left.PNG")
		RoomType.LEFT_OR_RIGHT_ONE:
			loaded_room = load("res://entities/rooms/left_or_right_one.PNG")
		RoomType.LEFT_OR_RIGHT_TWO:
			loaded_room = load("res://entities/rooms/left_or_right_two.PNG")
		RoomType.RIGHT:
			loaded_room = load("res://entities/rooms/right.PNG")
		RoomType.ROOM:
			loaded_room = load("res://entities/rooms/room.PNG")
		RoomType.TITLE_CARD:
			loaded_room = load("res://entities/rooms/title_card.png")
		_:
			loaded_room = load("res://entities/cards/blank_card.png")
	
	room_image.texture = loaded_room
