extends Node3D

var mouse_sense = 0.1

@onready var hands = %Hands
@onready var default_hand_position = hands.position

func _input(event):
	if event is InputEventMouseMotion:
		owner.rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))
		sway(event.relative)

func _process(delta):
	hands.position.x = lerp(hands.position.x, default_hand_position.x, delta * 5)
	hands.position.y = lerp(hands.position.y, default_hand_position.y, delta * 5)

func sway(sway_amount: Vector2) -> void:
	hands.position.x -= sway_amount.x * 0.0001
	hands.position.y += sway_amount.y * 0.0001
