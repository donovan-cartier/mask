extends Area3D
class_name TP


@export var scene: PackedScene
signal _on_tp(scene: PackedScene)

func _ready() -> void:
	await get_tree().process_frame
	_on_tp.connect(Nodes.world.change_map_to)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_on_tp.emit(scene)
