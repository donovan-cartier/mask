extends Node
class_name NPCCensorViewportComponent

## Viewport-based NPC censorship with billboard pixels that overflow the mesh

@export var target_npc: Node3D
@export_group("Viewport Settings")
@export var viewport_resolution: int = 128
@export_group("Shader Settings")
@export var pixel_size: float = 8.0
@export var dither_threshold: float = 0.5
@export var overflow_scale: float = 1.2

var sub_viewport: SubViewport
var viewport_camera: Camera3D
var billboard_sprite: Sprite3D
var shader_material: ShaderMaterial
var main_camera: Camera3D


func _ready() -> void:
	if target_npc == null:
		target_npc = get_parent() as Node3D

	# Don't activate if we're inside a SubViewport (we're a clone)
	if get_viewport() is SubViewport:
		return

	_enable_viewport_censorship()


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

	# Duplicate NPC into viewport
	var npc_clone = target_npc.duplicate()

	# Remove censor component from clone to avoid recursion
	for child in npc_clone.get_children():
		if child is NPCCensorViewportComponent:
			npc_clone.remove_child(child)
			child.queue_free()
			break

	sub_viewport.add_child(npc_clone)
	npc_clone.global_transform = target_npc.global_transform  # FIX: preserve world position
	_make_unshaded(npc_clone)

	print("=== DEBUG POSITIONS ===")
	print("target_npc: ", target_npc.name)
	print("target_npc.global_position: ", target_npc.global_position)
	print("target_npc.get_parent(): ", target_npc.get_parent().name)
	print("npc_clone.global_position: ", npc_clone.global_position)

	target_npc.visible = false

	# Create billboard sprite to display the viewport
	billboard_sprite = Sprite3D.new()
	billboard_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	billboard_sprite.texture = sub_viewport.get_texture()
	billboard_sprite.pixel_size = 0.01

	# Calculate sprite size based on NPC bounds
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
	print("billboard_sprite.global_position: ", billboard_sprite.global_position)
	print("main_camera.global_position: ", main_camera.global_position if main_camera else "null")


func _process(_delta: float) -> void:
	# Update viewport camera to match main camera
	if viewport_camera and main_camera:
		viewport_camera.global_transform = main_camera.global_transform
		viewport_camera.fov = main_camera.fov


func _make_unshaded(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		for i in mesh_instance.get_surface_override_material_count():
			var mat = mesh_instance.get_active_material(i)
			if mat is StandardMaterial3D:
				var unshaded_mat = mat.duplicate()
				unshaded_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				mesh_instance.set_surface_override_material(i, unshaded_mat)

	for child in node.get_children():
		_make_unshaded(child)


func _get_npc_aabb(npc: Node3D) -> AABB:
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
