extends Node2D

@onready var music_card := get_node("Background/MusicCard")
@onready var art_card 	:= get_node("Background/ArtCard")
@onready var dev_card 	:= get_node("Background/DevCard")
@onready var focused_card_scale = Vector2(0.30, 0.30)
@onready var original_card_scale = Vector2(0.25, 0.25)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_art_shape_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		OS.shell_open("https://www.instagram.com/antisocial.dinos/")

func _on_art_shape_2d_mouse_entered() -> void:
	art_card.scale = focused_card_scale

func _on_art_shape_2d_mouse_exited() -> void:
	art_card.scale = original_card_scale


func _on_music_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		OS.shell_open("https://onemansymphony.bandcamp.com/album/downtempo-lofi-progressive-music-pack-vol-1-free")

func _on_music_area_2d_mouse_entered() -> void:
	music_card.scale = focused_card_scale

func _on_music_area_2d_mouse_exited() -> void:
	music_card.scale = original_card_scale


func _on_dev_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"): # set this up in project settings
		OS.shell_open("https://github.com/ofgrenudo/AllegoryCave")

func _on_dev_area_2d_mouse_entered() -> void:
	dev_card.scale = focused_card_scale

func _on_dev_area_2d_mouse_exited() -> void:
	dev_card.scale = original_card_scale

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Sceens/Main Menu.tscn")
