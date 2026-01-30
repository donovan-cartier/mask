extends Node
class_name DisappearComponent

enum TimePeriod {
	PAST,
	PRESENT,
	FUTURE
}

# TODO: faire en fonction du time period
@export var time_period: TimePeriod = TimePeriod.PRESENT
@export var custom_owner: Node3D

signal disappeared
signal reappeared

func _ready():
	if custom_owner:
		owner = custom_owner
	assert(owner is StaticBody3D, "Faut que le owner soit un StaticBody3D mon bro")
	Nodes.player.toggle_time_period.connect(_on_time_toggle)

func disappear():
	owner.visible = false
	owner.set_collision_layer(0)
	owner.set_collision_mask(0)
	disappeared.emit()

func reappear():
	owner.visible = true
	owner.set_collision_layer(1)
	owner.set_collision_mask(1)
	reappeared.emit()

func _on_time_toggle():
	if owner.visible:
		disappear()
	else:
		reappear()
