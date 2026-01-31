extends Node3D

var mouse_sense = 0.1

func _input(event):
	if event is InputEventMouseMotion:
		owner.rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))
