extends Area3D
class_name TP


@export var scene: PackedScene
@onready var ring: MeshInstance3D = $Ring
@onready var light: OmniLight3D = $OmniLight3D

signal _on_tp(scene: PackedScene)

var time: float = 0.0

func _ready() -> void:
	await get_tree().process_frame
	_on_tp.connect(Nodes.world.change_map_to)

func _process(delta: float) -> void:
	time += delta * 2.0
	var pulse = (sin(time) + 1.0) / 2.0

	ring.scale = Vector3(1.0 + pulse * 0.1, 1.0, 1.0 + pulse * 0.1)
	light.light_energy = 1.5 + pulse * 1.0

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_on_tp.emit(scene)
