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
		# TODO: Implement smooth transition with Tween
		# For now, use instant transition
		environment = target_env
