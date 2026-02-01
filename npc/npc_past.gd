extends Node3D
class_name NPCPast

## NPC that only appears in the PAST time period with viewport censorship shader
## This is a background character with no gameplay interaction

@export_group("NPC Model")
@export var npc_model: Node3D  # Reference to the actual 3D model (optional, can use children)

@export_group("Censorship Settings")
@export var viewport_resolution: int = 128
@export var pixel_size: float = 8.0
@export var dither_threshold: float = 0.5
@export var overflow_scale: float = 1.2

var censor_component: NPCCensorViewportComponent


func _ready() -> void:
	print("[NPCPast] Initializing...")

	# Use first Node3D child as model if not specified
	if npc_model == null:
		for child in get_children():
			if child is Node3D and not child is NPCCensorViewportComponent:
				npc_model = child
				break

	assert(npc_model != null, "NPCPast needs a 3D model as child or npc_model export set!")
	print("[NPCPast] Found model: ", npc_model.name)

	# Wait for player to be ready if not yet initialized
	if Nodes.player == null:
		print("[NPCPast] Waiting for player to initialize...")
		await get_tree().process_frame

	print("[NPCPast] Player ready, current period: ", Nodes.player.current_time_period)

	# Add viewport-based censorship component for PAST time period
	censor_component = NPCCensorViewportComponent.new()
	censor_component.target_npc = npc_model
	censor_component.viewport_resolution = viewport_resolution
	censor_component.pixel_size = pixel_size
	censor_component.dither_threshold = dither_threshold
	censor_component.overflow_scale = overflow_scale
	add_child(censor_component)

	print("[NPCPast] Censorship component added")
