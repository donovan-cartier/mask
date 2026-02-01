extends CharacterBody3D
class_name Player

const SPEED = 5.0
const RUN_SPEED = 12.0
const JUMP_VELOCITY = 4.0
const GRAVITY = 9.8

@export var camera: Camera3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var head: Node3D = %Head

var current_time_period: TimeComponent.TimePeriod = TimeComponent.TimePeriod.PRESENT

signal changed_time_period(new_time_period: TimeComponent.TimePeriod)

func _ready():
	Nodes.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.animation_finished.connect(_on_animation_finished)


func _on_animation_finished(_anim_name: String) -> void:
	head.start_flicker(2.0)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == Key.KEY_F1:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement (always available, but no sprint in air)
	var calculated_speed: float = _calculate_speed()
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * calculated_speed
		velocity.z = direction.z * calculated_speed
	else:
		velocity.x = move_toward(velocity.x, 0, calculated_speed)
		velocity.z = move_toward(velocity.z, 0, calculated_speed)

	_handle_time_period_change()

	move_and_slide()

func _calculate_speed() -> float:
	if Input.is_action_pressed("run"):
		return RUN_SPEED
	return SPEED

func _handle_time_period_change() -> void:
	if animation_player.is_playing():
		return 

	if Input.is_action_just_pressed("previous_time_period"):
		if current_time_period == TimeComponent.TimePeriod.PAST:
			return

		var previous_time_period: TimeComponent.TimePeriod = _get_previous_time_period(current_time_period)
		current_time_period = previous_time_period
		animation_player.play("arms_anim")

	elif Input.is_action_just_pressed("next_time_period"):
		if current_time_period == TimeComponent.TimePeriod.FUTURE:
			return

		var next_time_period: TimeComponent.TimePeriod = _get_next_time_period(current_time_period)
		current_time_period = next_time_period

		animation_player.play("arms_anim")

func _get_previous_time_period(current: TimeComponent.TimePeriod) -> TimeComponent.TimePeriod:
	match current:
		TimeComponent.TimePeriod.PRESENT:
			return TimeComponent.TimePeriod.PAST
		TimeComponent.TimePeriod.FUTURE:
			return TimeComponent.TimePeriod.PRESENT

	return current


func _get_next_time_period(current: TimeComponent.TimePeriod) -> TimeComponent.TimePeriod:
	match current:
		TimeComponent.TimePeriod.PAST:
			return TimeComponent.TimePeriod.PRESENT
		TimeComponent.TimePeriod.PRESENT:
			return TimeComponent.TimePeriod.FUTURE

	return current

func _get_random_time_period_excluding(exclude: TimeComponent.TimePeriod) -> TimeComponent.TimePeriod:
	var periods = [
		TimeComponent.TimePeriod.PAST,
		TimeComponent.TimePeriod.PRESENT,
		TimeComponent.TimePeriod.FUTURE
	]
	periods.erase(exclude)
	return periods.pick_random()

func hit():
	var random_time_period: TimeComponent.TimePeriod = _get_random_time_period_excluding(current_time_period)
	current_time_period = random_time_period
	changed_time_period.emit(random_time_period)
	head.shake(0.2, 4.0)  # Screen shake feedback

func trigger_change_time_period() -> void:
	changed_time_period.emit(current_time_period)
