extends Node3D
class_name RadarHudComponent

## Retro radar HUD that shows player orientation and time period

@export var sphere_mesh: MeshInstance3D
@export var cardinal_indicators: Node3D

@export_group("Rotation")
@export var smooth_rotation: bool = true
@export var rotation_speed: float = 8.0

@export_group("Colors")
@export var color_past: Color = Color(0.2, 0.6, 0.9)      # Cold blue
@export var color_present: Color = Color(1.0, 0.5, 0.1)   # Orange
@export var color_future: Color = Color(0.5, 0.7, 0.5)    # Grey-green

var shader_material: ShaderMaterial
var target_rotation_y: float = 0.0


func _ready() -> void:
	# Get shader material from sphere
	shader_material = sphere_mesh.material_override as ShaderMaterial
	assert(shader_material != null, "RadarHudComponent requires sphere with ShaderMaterial!")

	# Wait for player to be ready if not yet initialized
	if Nodes.player == null:
		await get_tree().process_frame

	# Connect to player signals (pattern from particle_manager.gd)
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

	# Set initial color
	_update_color(Nodes.player.current_time_period)


func _process(delta: float) -> void:
	# Update target rotation from player yaw (inverse rotation for compass effect)
	target_rotation_y = -Nodes.player.rotation.y

	# Apply rotation (smooth or direct)
	if smooth_rotation:
		rotation.y = lerp_angle(rotation.y, target_rotation_y, rotation_speed * delta)
	else:
		rotation.y = target_rotation_y

	# Keep cardinal indicators fixed (counter-rotate to cancel parent rotation)
	if cardinal_indicators:
		cardinal_indicators.rotation.y = -rotation.y


func _on_time_period_changed(new_period: TimeComponent.TimePeriod) -> void:
	_update_color(new_period)


func _update_color(period: TimeComponent.TimePeriod) -> void:
	var new_color: Color
	match period:
		TimeComponent.TimePeriod.PAST:
			new_color = color_past
		TimeComponent.TimePeriod.PRESENT:
			new_color = color_present
		TimeComponent.TimePeriod.FUTURE:
			new_color = color_future

	# Update shader parameter (pattern from npc_censor_viewport_component.gd)
	shader_material.set_shader_parameter("line_color", Vector3(new_color.r, new_color.g, new_color.b))
