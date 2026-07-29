extends Control

## The Main Menu Sceene!
##
## The Main Menu should really only navigate us from here to one of the following options
## - Starting the Game
## - Game Settings
## - Safely Quitting the Game!

## Load our Settings Sceen on Ready
@onready var settings_scene := preload("res://Scenes/Settings/Settings.tscn")
@onready var credits_sceen := preload("res://Scenes/Credits/Credits.tscn")
## Load our Beginning Level
@onready var opening_scene := preload("res://Scenes/Opening Sceen/Opening Sceen.tscn")
@onready var music := get_node("Background/AudioStreamPlayer2D")

const HOVER_ROT_KICK := 0.06    ## How much the button un-slants on hover (radians)
const HOVER_SCALE    := 1.08    ## How much it grows on hover
const KICK_DURATION  := 0.12    ## Snappy — Persona is fast

var _button_rest_state: Dictionary = {}  # button -> {scale, rotation}

func _ready() -> void:
	var shelf: VBoxContainer = $"Vertical Shelf"
	# Wait one frame so the VBoxContainer has actually laid out its children
	# before we capture their resting transforms. Without this, everything
	# reads (0,0) and hover snaps every button to the top of the shelf.
	await get_tree().process_frame

	for child in shelf.get_children():
		if child is Button:
			_wire_button(child)

	# Give the Start button initial focus so keyboard/gamepad work right away.
	var start_btn := $"Vertical Shelf/Start" as Button
	if start_btn:
		start_btn.grab_focus()

func _wire_button(btn: Button) -> void:
	# Pivot around the center so scale/rotation feel right.
	btn.pivot_offset = btn.size * 0.5

	# Remember its resting transform so we can kick relative to it. We ONLY
	# tween scale + rotation (never position) because VBoxContainer owns
	# the position of its children and will fight us for it.
	_button_rest_state[btn] = {
		"scale":    btn.scale,
		"rotation": btn.rotation,
	}
	btn.mouse_entered.connect(func(): _kick(btn, true))
	btn.mouse_exited.connect(func(): _kick(btn, false))
	btn.focus_entered.connect(func(): _kick(btn, true))
	btn.focus_exited.connect(func(): _kick(btn, false))

func _kick(btn: Button, active: bool) -> void:
	if not _button_rest_state.has(btn):
		return
	var rest: Dictionary = _button_rest_state[btn]
	var target_scale: Vector2 = (rest["scale"] as Vector2) * (HOVER_SCALE if active else 1.0)
	# On hover, straighten the button a bit (like it's standing up to be noticed).
	var target_rot: float = (rest["rotation"] as float) + (HOVER_ROT_KICK if active else 0.0)

	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", target_scale, KICK_DURATION)
	tween.tween_property(btn, "rotation", target_rot, KICK_DURATION)

## This will navigate you to the starting scene when clicked.
func _on_start_pressed() -> void:
	Global.reset_run()  ## Fresh HP + room counter every new run
	get_tree().change_scene_to_packed(opening_scene) ## Load our Opening Sceene

## This will change to the settings scene when ran.
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_packed(settings_scene) ## Loads our Settings Sceene

## This will safely, quit the game when ran.
func _on_quit_pressed() -> void:
	get_tree().quit() ## Safely Exits the Game.

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_packed(credits_sceen)
