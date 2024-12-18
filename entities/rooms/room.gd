class_name Room extends Control

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

@export var selected_room: RoomType = RoomType.FORWARD_LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_selected_room()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_selected_room():
	pass
