extends CharacterBody3D
class_name Player

const SPEED = 5.0
const RUN_SPEED = 8.0
const JUMP_VELOCITY = 4.5

@export var camera: Camera3D

signal toggle_time_period

func _ready():
	Nodes.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == Key.KEY_ESCAPE:
		get_tree().quit()

	elif event is InputEventKey and event.pressed and event.keycode == Key.KEY_F1:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var calculated_speed: float = _calculate_speed()

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * calculated_speed
		velocity.z = direction.z * calculated_speed
	else:
		velocity.x = move_toward(velocity.x, 0, calculated_speed)
		velocity.z = move_toward(velocity.z, 0, calculated_speed)

	if Input.is_action_just_pressed("toggle_past"):
		toggle_time_period.emit()

	move_and_slide()

func _calculate_speed() -> float:
	if Input.is_action_pressed("run"):
		return RUN_SPEED
	return SPEED
