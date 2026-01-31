extends Node
class_name NPCCensorViewportComponent

## Viewport-based NPC censorship with billboard pixels that overflow the mesh

@export var target_npc: Node3D
@export_group("Viewport Settings")
@export var viewport_resolution: int = 128
@export_group("Shader Settings")
@export var pixel_size: float = 8.0
@export var dither_threshold: float = 0.5
@export var overflow_scale: float = 1.2  # How much pixels overflow the mesh (1.0 = no overflow, 1.5 = 50% larger)

var sub_viewport: SubViewport
var viewport_camera: Camera3D
var billboard_sprite: Sprite3D
var shader_material: ShaderMaterial
var main_camera: Camera3D


func _ready() -> void:
	# Use parent as target if not specified
	if target_npc == null:
		target_npc = get_parent() as Node3D
		assert(target_npc != null, "NPCCensorViewportComponent must have a Node3D parent or target_npc set!")

	# Don't activate if we're inside a SubViewport (we're a clone)
	var current_viewport = get_viewport()
	if current_viewport is SubViewport:
		return

	# Connect to time period changes
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

	# Apply initial state
	_update_censorship(Nodes.player.current_time_period)


func _on_time_period_changed(new_period: TimeComponent.TimePeriod) -> void:
	_update_censorship(new_period)


func _update_censorship(period: TimeComponent.TimePeriod) -> void:
	if period == TimeComponent.TimePeriod.PAST:
		_enable_viewport_censorship()
	else:
		_disable_viewport_censorship()


func _enable_viewport_censorship() -> void:
	# Create SubViewport
	sub_viewport = SubViewport.new()
	sub_viewport.size = Vector2i(viewport_resolution, viewport_resolution)
	sub_viewport.transparent_bg = true
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(sub_viewport)

	# Create camera in viewport
	viewport_camera = Camera3D.new()
	sub_viewport.add_child(viewport_camera)

	# Find main camera
	main_camera = get_viewport().get_camera_3d()

	# Duplicate NPC into viewport (keep original hidden)
	var npc_clone = target_npc.duplicate()

	# Remove the censor component from the clone to avoid recursion
	for child in npc_clone.get_children():
		if child is NPCCensorViewportComponent:
			npc_clone.remove_child(child)
			child.queue_free()
			break

	sub_viewport.add_child(npc_clone)
	target_npc.visible = false

	# Create billboard sprite to display the viewport
	billboard_sprite = Sprite3D.new()
	billboard_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	billboard_sprite.texture = sub_viewport.get_texture()
	billboard_sprite.pixel_size = 0.01  # Adjust to match NPC size

	# Calculate sprite size based on NPC bounds and overflow
	var npc_aabb = _get_npc_aabb(target_npc)
	var sprite_size = max(npc_aabb.size.x, npc_aabb.size.y) * overflow_scale
	billboard_sprite.scale = Vector3(sprite_size, sprite_size, sprite_size)

	# Setup shader material
	var shader = load("res://shaders/npc_censor_viewport.gdshader")
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("pixel_size", pixel_size)
	shader_material.set_shader_parameter("dither_threshold", dither_threshold)
	billboard_sprite.material_override = shader_material

	target_npc.add_child(billboard_sprite)


func _disable_viewport_censorship() -> void:
	# Show original NPC
	if target_npc:
		target_npc.visible = true

	# Clean up viewport and sprite
	if billboard_sprite:
		billboard_sprite.queue_free()
		billboard_sprite = null

	if sub_viewport:
		sub_viewport.queue_free()
		sub_viewport = null

	viewport_camera = null
	main_camera = null


func _process(_delta: float) -> void:
	# Update viewport camera to match main camera
	if viewport_camera and main_camera:
		viewport_camera.global_transform = main_camera.global_transform
		viewport_camera.fov = main_camera.fov


func _get_npc_aabb(npc: Node3D) -> AABB:
	# Calculate combined AABB of all MeshInstance3D children
	var combined_aabb = AABB()
	var first = true

	for child in npc.get_children():
		if child is MeshInstance3D:
			var mesh_aabb = child.get_aabb()
			if first:
				combined_aabb = mesh_aabb
				first = false
			else:
				combined_aabb = combined_aabb.merge(mesh_aabb)

	return combined_aabb if not first else AABB(Vector3.ZERO, Vector3.ONE)
