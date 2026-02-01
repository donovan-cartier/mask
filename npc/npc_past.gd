extends Node3D
class_name NPCPast

## NPC avec effet de censure viewport

@export var npc_model: Node3D
@export var pixel_size: float = 8.0
@export var dither_threshold: float = 0.5
@export var overflow_scale: float = 1.2


func _ready() -> void:
	# Find model if not set
	if npc_model == null:
		for child in get_children():
			if child is Node3D:
				npc_model = child
				break

	if npc_model == null:
		push_error("NPCPast: no model found")
		return

	# Add censor effect
	var censor = NPCCensorViewportComponent.new()
	censor.target_npc = npc_model
	censor.pixel_size = pixel_size
	censor.dither_threshold = dither_threshold
	censor.overflow_scale = overflow_scale
	add_child(censor)
