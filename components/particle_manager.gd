extends Node3D
class_name ParticleManager

## Gère l'activation/désactivation des systèmes de particules selon l'époque
## Suit la position de la caméra pour un effet immersif

@export_group("Particle Groups")
@export var past_particles: Node3D
@export var present_particles: Node3D
@export var future_particles: Node3D

@export_group("Camera Tracking")
@export var follow_camera: bool = true
@export var camera: Camera3D
@export var follow_speed: float = 5.0


func _ready() -> void:
	# Vérifier que les groupes de particules sont assignés
	assert(past_particles != null, "Past particles node n'est pas assigné!")
	assert(present_particles != null, "Present particles node n'est pas assigné!")
	assert(future_particles != null, "Future particles node n'est pas assigné!")

	# Se connecter au signal du joueur
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

	# Activer les particules initiales
	_activate_particles(Nodes.player.current_time_period)

	# Récupérer la caméra si non assignée
	if follow_camera and camera == null:
		camera = Nodes.player.camera


func _process(delta: float) -> void:
	if follow_camera and camera != null:
		# Suivre la position de la caméra en douceur
		global_position = global_position.lerp(camera.global_position, follow_speed * delta)


func _on_time_period_changed(new_time_period: TimeComponent.TimePeriod) -> void:
	_activate_particles(new_time_period)


func _activate_particles(time_period: TimeComponent.TimePeriod) -> void:
	# Désactiver toutes les particules
	_set_particles_active(past_particles, false)
	_set_particles_active(present_particles, false)
	_set_particles_active(future_particles, false)

	# Activer les particules de l'époque courante
	match time_period:
		TimeComponent.TimePeriod.PAST:
			_set_particles_active(past_particles, true)
		TimeComponent.TimePeriod.PRESENT:
			_set_particles_active(present_particles, true)
		TimeComponent.TimePeriod.FUTURE:
			_set_particles_active(future_particles, true)


func _set_particles_active(parent_node: Node3D, active: bool) -> void:
	"""Active ou désactive tous les GPUParticles3D enfants d'un node"""
	if parent_node == null:
		return

	for child in parent_node.get_children():
		if child is GPUParticles3D:
			if not active:
				# Réinitialiser les particules pour les effacer immédiatement
				child.restart()
			child.emitting = active
