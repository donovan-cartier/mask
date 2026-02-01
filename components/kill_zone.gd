extends Area3D
class_name KillZone

## Zone that triggers game over when player enters

const GAME_OVER_SCENE = preload("res://ui/game_over.tscn")

@export var delay: float = 1.0

var game_over_instance: Node


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_trigger_game_over()


func _trigger_game_over() -> void:
	# Freeze player
	Nodes.player.set_physics_process(false)
	Nodes.player.set_process_input(false)

	# Screen effect
	Nodes.player.head.shake(0.3, 2.0)

	# Wait then show game over
	await get_tree().create_timer(delay).timeout

	# Show game over screen
	game_over_instance = GAME_OVER_SCENE.instantiate()
	get_tree().current_scene.add_child(game_over_instance)
	game_over_instance.show_game_over()
