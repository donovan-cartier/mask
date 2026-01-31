extends Node
class_name TimeComponent

enum TimePeriod {
	PAST,
	PRESENT,
	FUTURE
}

@export var time_period: TimePeriod = TimePeriod.PRESENT
@export var custom_owner: Node3D
@export var invert: bool = false

signal disappeared
signal reappeared

func _ready():
	if custom_owner:
		owner = custom_owner
	assert(owner is StaticBody3D, "Faut que le owner soit un StaticBody3D mon bro")
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

	if Nodes.player.current_time_period == time_period && !invert:
		reappear()
	else:
		disappear()

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

func _on_time_period_changed(new_time_period: TimePeriod) -> void:
	if invert:
		if new_time_period != time_period:
			reappear()
		else:
			disappear()
	else:
		if new_time_period == time_period:
			reappear()
		else:
			disappear()
