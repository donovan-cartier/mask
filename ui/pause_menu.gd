extends Control
class_name PauseMenu

@onready var resume_button: Button = %ResumeButton
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton

var is_paused: bool = false


func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume)
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()


func toggle_pause() -> void:
	if is_paused:
		_resume()
	else:
		_pause()


func _pause() -> void:
	is_paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	visible = true
	resume_button.grab_focus()


func _resume() -> void:
	is_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	visible = false


func _on_resume() -> void:
	_resume()


func _on_retry() -> void:
	is_paused = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu() -> void:
	is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
