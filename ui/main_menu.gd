extends Control

const GAME_SCENE = "res://world.tscn"
const ARCADE_SCENE = "res://levels/level_run.tscn"

@onready var play_button: Button = %PlayButton
@onready var arcade_button: Button = %ArcadeButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	play_button.grab_focus()
	play_button.pressed.connect(_on_play_pressed)
	arcade_button.pressed.connect(_on_arcade_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_arcade_pressed() -> void:
	get_tree().change_scene_to_file(ARCADE_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
