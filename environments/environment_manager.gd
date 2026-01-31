extends WorldEnvironment
class_name EnvironmentManager

## Gère les transitions d'environnement entre les trois époques
## Se connecte au signal changed_time_period du Player pour changer l'ambiance

# Références aux 3 environnements (assignées dans l'éditeur)
@export_group("Environments")
@export var past_environment: Environment
@export var present_environment: Environment
@export var future_environment: Environment

@export_group("Transition")
## Durée de la transition en secondes (0 = instantané)
@export_range(0.0, 2.0, 0.1) var transition_duration: float = 0.0


func _ready() -> void:
	# Vérifier que les environments sont assignés
	assert(past_environment != null, "Past environment n'est pas assigné!")
	assert(present_environment != null, "Present environment n'est pas assigné!")
	assert(future_environment != null, "Future environment n'est pas assigné!")

	# Se connecter au signal du joueur
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

	# Appliquer l'environnement initial
	_apply_environment(Nodes.player.current_time_period)


func _on_time_period_changed(new_time_period: TimeComponent.TimePeriod) -> void:
	_apply_environment(new_time_period)


func _apply_environment(time_period: TimeComponent.TimePeriod) -> void:
	var target_env: Environment

	match time_period:
		TimeComponent.TimePeriod.PAST:
			target_env = past_environment
		TimeComponent.TimePeriod.PRESENT:
			target_env = present_environment
		TimeComponent.TimePeriod.FUTURE:
			target_env = future_environment
		_:
			push_error("TimePeriod inconnu: " + str(time_period))
			return

	if transition_duration <= 0.0:
		# Transition instantanée (effet glitch)
		environment = target_env
	else:
		# TODO: Implémenter transition fluide avec Tween
		# Pour l'instant, on fait instantané
		environment = target_env
