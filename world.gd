extends Node3D
class_name World

@export var current_map: Node3D

func _ready() -> void:
	Nodes.world = self

func change_map_to(scene: PackedScene):
	if current_map:
		current_map.queue_free()
	
	var map_i = scene.instantiate()
	add_child(map_i)
	current_map = map_i
	Nodes.player.global_transform = current_map.get_node("Spawn").global_transform
