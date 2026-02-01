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
var hidden_meshes: Array[MeshInstance3D] = []


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
	print("[NPCCensor] Update censorship for period: ", period)
	if period == TimeComponent.TimePeriod.PAST:
		print("[NPCCensor] Enabling viewport censorship")
		_enable_viewport_censorship()
	else:
		print("[NPCCensor] Disabling viewport censorship")
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

	# Reset clone position to viewport origin (keep rotation/scale)
	npc_clone.position = Vector3.ZERO
	sub_viewport.add_child(npc_clone)

	# Hide original NPC meshes (not the whole node, to keep billboard visible)
	hidden_meshes = _find_all_meshes(target_npc)
	for mesh in hidden_meshes:
		mesh.visible = false

	# Create billboard sprite to display the viewport
	billboard_sprite = Sprite3D.new()
	billboard_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	billboard_sprite.texture = sub_viewport.get_texture()
	billboard_sprite.pixel_size = 0.01
	billboard_sprite.layers = 2  # Same layer as the NPC meshes

	# Calculate sprite size based on NPC bounds and overflow
	var npc_aabb = _get_npc_aabb(target_npc)
	print("[NPCCensor] NPC AABB: ", npc_aabb)
	var sprite_size = max(npc_aabb.size.x, npc_aabb.size.y) * overflow_scale
	print("[NPCCensor] Billboard sprite size: ", sprite_size)
	billboard_sprite.scale = Vector3(sprite_size, sprite_size, sprite_size)

	# Setup shader material
	var shader = load("res://shaders/npc_censor_viewport.gdshader")
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("pixel_size", pixel_size)
	shader_material.set_shader_parameter("dither_threshold", dither_threshold)
	billboard_sprite.material_override = shader_material

	target_npc.add_child(billboard_sprite)
	print("[NPCCensor] Billboard sprite created and added to ", target_npc.name)


func _disable_viewport_censorship() -> void:
	# Restore mesh visibility before hiding whole node
	for mesh in hidden_meshes:
		if mesh:
			mesh.visible = true
	hidden_meshes.clear()

	# Hide NPC - they only exist in the PAST
	if target_npc:
		target_npc.visible = false

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
	# Update viewport camera to match main camera's viewing angle
	if viewport_camera and main_camera and target_npc:
		# Calculate transform from NPC's local space to camera
		var npc_to_camera = target_npc.global_transform.affine_inverse() * main_camera.global_transform

		# Apply this relative transform to viewport camera
		# (positions camera relative to clone the same way main camera is relative to original)
		viewport_camera.transform = npc_to_camera
		viewport_camera.fov = main_camera.fov


func _get_npc_aabb(npc: Node3D) -> AABB:
	# Calculate combined AABB of all MeshInstance3D descendants (recursive search)
	var meshes = _find_all_meshes(npc)

	if meshes.is_empty():
		return AABB(Vector3.ZERO, Vector3.ONE)

	var combined_aabb = meshes[0].get_aabb()
	for i in range(1, meshes.size()):
		combined_aabb = combined_aabb.merge(meshes[i].get_aabb())

	return combined_aabb


func _find_all_meshes(node: Node, depth: int = 0) -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []

	if depth > 10:  # Prevent infinite recursion
		return meshes

	for child in node.get_children():
		if child is MeshInstance3D:
			meshes.append(child)
		# Continue searching in children recursively
		if child.get_child_count() > 0:
			meshes.append_array(_find_all_meshes(child, depth + 1))

	return meshes
