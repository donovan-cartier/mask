extends Control
class_name UI

@export var time_period_label: Label

func _ready():
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

func _on_time_period_changed(new_time_period: TimeComponent.TimePeriod) -> void:
	time_period_label.text = TimeComponent.TimePeriod.keys()[new_time_period]