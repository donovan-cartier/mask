extends Node3D
class_name ParticleManager

## Manages particle systems activation/deactivation based on time period
## Follows camera position for an immersive effect

@export_group("Particle Groups")
@export var past_particles: Node3D
@export var present_particles: Node3D
@export var future_particles: Node3D

@export_group("Camera Tracking")
@export var follow_camera: bool = true
@export var camera: Camera3D
@export var follow_speed: float = 5.0


func _ready() -> void:
	# Verify that particle groups are assigned
	assert(past_particles != null, "Past particles node is not assigned!")
	assert(present_particles != null, "Present particles node is not assigned!")
	assert(future_particles != null, "Future particles node is not assigned!")

	# Connect to player signal
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

	# Activate initial particles
	_activate_particles(Nodes.player.current_time_period)

	# Get camera if not assigned
	if follow_camera and camera == null:
		camera = Nodes.player.camera


func _process(delta: float) -> void:
	if follow_camera and camera != null:
		# Smoothly follow camera position
		global_position = global_position.lerp(camera.global_position, follow_speed * delta)


func _on_time_period_changed(new_time_period: TimeComponent.TimePeriod) -> void:
	_activate_particles(new_time_period)


func _activate_particles(time_period: TimeComponent.TimePeriod) -> void:
	# Deactivate all particles
	_set_particles_active(past_particles, false)
	_set_particles_active(present_particles, false)
	_set_particles_active(future_particles, false)

	# Activate particles for current time period
	match time_period:
		TimeComponent.TimePeriod.PAST:
			_set_particles_active(past_particles, true)
		TimeComponent.TimePeriod.PRESENT:
			_set_particles_active(present_particles, true)
		TimeComponent.TimePeriod.FUTURE:
			_set_particles_active(future_particles, true)


func _set_particles_active(parent_node: Node3D, active: bool) -> void:
	"""Activates or deactivates all GPUParticles3D children of a node"""
	if parent_node == null:
		return

	for child in parent_node.get_children():
		if child is GPUParticles3D:
			if not active:
				# Reset particles to clear them immediately
				child.restart()
			child.emitting = active
