extends WorldEnvironment
class_name EnvironmentManager

## Manages environment transitions between the three time periods
## Connects to Player's changed_time_period signal to change atmosphere

# References to the 3 environments (assigned in editor)
@export_group("Environments")
@export var past_environment: Environment
@export var present_environment: Environment
@export var future_environment: Environment

@export_group("Transition")
## Transition duration in seconds (0 = instant)
@export_range(0.0, 2.0, 0.1) var transition_duration: float = 0.0

var current_tween: Tween


func _ready() -> void:
	# Verify that environments are assigned
	assert(past_environment != null, "Past environment is not assigned!")
	assert(present_environment != null, "Present environment is not assigned!")
	assert(future_environment != null, "Future environment is not assigned!")

	# Connect to player signal
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

	# Apply initial environment
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
			push_error("Unknown TimePeriod: " + str(time_period))
			return

	if transition_duration <= 0.0:
		# Instant transition (glitch effect)
		environment = target_env
	else:
		_transition_to(target_env)


func _transition_to(target_env: Environment) -> void:
	# Kill any existing tween
	if current_tween and current_tween.is_valid():
		current_tween.kill()

	# Store TARGET values BEFORE any modifications
	var target_ambient = target_env.ambient_light_color
	var target_ambient_energy = target_env.ambient_light_energy
	var target_fog_color = target_env.fog_light_color
	var target_fog_density = target_env.fog_density
	var target_exposure = target_env.tonemap_exposure
	var target_glow = target_env.glow_intensity

	# Store current values
	var current_ambient = environment.ambient_light_color
	var current_ambient_energy = environment.ambient_light_energy
	var current_fog_color = environment.fog_light_color
	var current_fog_density = environment.fog_density
	var current_exposure = environment.tonemap_exposure
	var current_glow = environment.glow_intensity

	# Switch to target environment
	environment = target_env

	# Reset to old values (will tween to target)
	environment.ambient_light_color = current_ambient
	environment.ambient_light_energy = current_ambient_energy
	environment.fog_light_color = current_fog_color
	environment.fog_density = current_fog_density
	environment.tonemap_exposure = current_exposure
	environment.glow_intensity = current_glow

	# Create tween
	current_tween = create_tween()
	current_tween.set_parallel(true)
	current_tween.set_ease(Tween.EASE_IN_OUT)
	current_tween.set_trans(Tween.TRANS_CUBIC)

	# Tween to stored target values
	current_tween.tween_property(environment, "ambient_light_color", target_ambient, transition_duration)
	current_tween.tween_property(environment, "ambient_light_energy", target_ambient_energy, transition_duration)
	current_tween.tween_property(environment, "fog_light_color", target_fog_color, transition_duration)
	current_tween.tween_property(environment, "fog_density", target_fog_density, transition_duration)
	current_tween.tween_property(environment, "tonemap_exposure", target_exposure, transition_duration)
	current_tween.tween_property(environment, "glow_intensity", target_glow, transition_duration)
