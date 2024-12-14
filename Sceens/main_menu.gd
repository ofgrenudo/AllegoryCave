extends Control

## The Main Menu Sceene!
##
## The Main Menu should really only navigate us from here to one of the following options
## - Starting the Game
## - Game Settings
## - Safely Quitting the Game!

## Load our Settings Sceen on Ready
@onready var settings_scene := preload("res://Sceens/Settings/Settings.tscn")
## Load our Beginning Level
@onready var opening_scene := preload("res://Sceens/Opening Sceen/Opening Sceen.tscn")



func _ready() -> void:
	pass # Replace with function body.

## This will navigate you to the starting scene when clicked.
func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(opening_scene) ## Load our Opening Sceene

## This will change to the settings scene when ran.
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_packed(settings_scene) ## Loads our Settings Sceene

## This will safely, quit the game when ran.
func _on_quit_pressed() -> void:
	get_tree().quit() ## Safely Exits the Game.
