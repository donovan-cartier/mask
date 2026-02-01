@tool

extends Node3D
class_name LevelScript

@export var preview_time_period: TimeComponent.TimePeriod = TimeComponent.TimePeriod.PRESENT:
	set(value):
		preview_time_period = value
		if Engine.is_editor_hint():
			get_tree().call_group("autobuilding", "update_type", preview_time_period)
