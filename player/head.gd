extends Node3D

var mouse_sense = 0.1
var flicker_timer = 0.0
var flicker_delay = 0.5  # Délai initial

# Screen shake
var shake_intensity: float = 0.0
var shake_decay: float = 5.0

@onready var hands = %Hands
@onready var default_hand_position = hands.position
@onready var m_screen = load("res://player/shifter/m_screen.tres")
@onready var camera: Camera3D = $Camera3D

func _input(event):
	if event is InputEventMouseMotion:
		owner.rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))
		sway(event.relative)

func _process(delta):
	hands.position.x = lerp(hands.position.x, default_hand_position.x, delta * 5)
	hands.position.y = lerp(hands.position.y, default_hand_position.y, delta * 5)
	flicker_timer -= delta
	if flicker_timer <= 0:
		random_flicker()
		flicker_timer = randf_range(0.1, .2)  # Délai aléatoire entre 0.1 et 1.0 secondes

	# Apply screen shake
	if shake_intensity > 0:
		camera.h_offset = randf_range(-shake_intensity, shake_intensity)
		camera.v_offset = randf_range(-shake_intensity, shake_intensity)
		shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
		if shake_intensity < 0.001:
			shake_intensity = 0.0
			camera.h_offset = 0.0
			camera.v_offset = 0.0

func random_flicker() -> void:
	var flicker_value = randf_range(0, 1.93)  # Valeur aléatoire entre 0 et 1
	m_screen.set("emission_energy_multiplier", flicker_value)

func sway(sway_amount: Vector2) -> void:
	hands.position.x -= sway_amount.x * 0.0001
	hands.position.y += sway_amount.y * 0.0001

func shake(intensity: float = 0.15, decay: float = 5.0) -> void:
	shake_intensity = intensity
	shake_decay = decay
