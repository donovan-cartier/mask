extends CanvasLayer
class_name GameOverScreen

@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton

var current_scene_path: String


func _ready() -> void:
	hide()
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)


func show_game_over() -> void:
	current_scene_path = get_tree().current_scene.scene_file_path
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	show()
	retry_button.grab_focus()


func _on_retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
