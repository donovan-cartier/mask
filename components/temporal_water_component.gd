extends Node
class_name TemporalWaterComponent

## Changes water shader parameters based on time period

@export var target_water: MeshInstance3D

@export_group("Past")
@export var past_color: Color = Color(0.15, 0.25, 0.35, 0.9)
@export var past_wave_speed: float = 0.5
@export var past_wave_strength: float = 0.03

@export_group("Present")
@export var present_color: Color = Color(0.1, 0.3, 0.5, 0.85)
@export var present_wave_speed: float = 1.0
@export var present_wave_strength: float = 0.08

@export_group("Future")
@export var future_color: Color = Color(0.05, 0.15, 0.25, 0.7)
@export var future_wave_speed: float = 2.0
@export var future_wave_strength: float = 0.15

@export_group("Transition")
@export var transition_duration: float = 0.5

var shader_material: ShaderMaterial
var current_tween: Tween


func _ready() -> void:
	if target_water == null:
		target_water = get_parent() as MeshInstance3D

	if target_water == null:
		push_error("TemporalWaterComponent: no MeshInstance3D target")
		return

	shader_material = target_water.get_surface_override_material(0) as ShaderMaterial
	if shader_material == null:
		shader_material = target_water.mesh.surface_get_material(0) as ShaderMaterial

	if shader_material == null:
		push_error("TemporalWaterComponent: no ShaderMaterial found")
		return

	Nodes.player.changed_time_period.connect(_on_time_period_changed)
	_apply_period(Nodes.player.current_time_period)


func _on_time_period_changed(new_period: TimeComponent.TimePeriod) -> void:
	_apply_period(new_period)


func _apply_period(period: TimeComponent.TimePeriod) -> void:
	var target_color: Color
	var target_speed: float
	var target_strength: float

	match period:
		TimeComponent.TimePeriod.PAST:
			target_color = past_color
			target_speed = past_wave_speed
			target_strength = past_wave_strength
		TimeComponent.TimePeriod.PRESENT:
			target_color = present_color
			target_speed = present_wave_speed
			target_strength = present_wave_strength
		TimeComponent.TimePeriod.FUTURE:
			target_color = future_color
			target_speed = future_wave_speed
			target_strength = future_wave_strength

	if transition_duration <= 0:
		shader_material.set_shader_parameter("water_color", target_color)
		shader_material.set_shader_parameter("wave_speed", target_speed)
		shader_material.set_shader_parameter("wave_strength", target_strength)
	else:
		_tween_to(target_color, target_speed, target_strength)


func _tween_to(color: Color, speed: float, strength: float) -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()

	current_tween = create_tween()
	current_tween.set_parallel(true)
	current_tween.set_ease(Tween.EASE_IN_OUT)
	current_tween.set_trans(Tween.TRANS_CUBIC)

	var current_color = shader_material.get_shader_parameter("water_color")
	var current_speed = shader_material.get_shader_parameter("wave_speed")
	var current_strength = shader_material.get_shader_parameter("wave_strength")

	current_tween.tween_method(
		func(c): shader_material.set_shader_parameter("water_color", c),
		current_color, color, transition_duration
	)
	current_tween.tween_method(
		func(s): shader_material.set_shader_parameter("wave_speed", s),
		current_speed, speed, transition_duration
	)
	current_tween.tween_method(
		func(s): shader_material.set_shader_parameter("wave_strength", s),
		current_strength, strength, transition_duration
	)
