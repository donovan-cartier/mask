extends CanvasLayer
class_name EpochHud

## HUD displaying the current time period with 3 stacked icons
## Active epoch is colored, inactive ones are dimmed

@export_group("Textures")
@export var texture_past: TextureRect
@export var texture_present: TextureRect
@export var texture_future: TextureRect

func _ready() -> void:
	if Nodes.player == null:
		await get_tree().process_frame

	Nodes.player.changed_time_period.connect(_on_time_period_changed)
	_update_display(Nodes.player.current_time_period)


func _on_time_period_changed(new_period: TimeComponent.TimePeriod) -> void:
	_update_display(new_period)


func _update_display(period: TimeComponent.TimePeriod) -> void:
	# Hide all
	if texture_past:
		texture_past.visible = false
	if texture_present:
		texture_present.visible = false
	if texture_future:
		texture_future.visible = false

	# Show active epoch
	match period:
		TimeComponent.TimePeriod.PAST:
			if texture_past:
				texture_past.visible = true
		TimeComponent.TimePeriod.PRESENT:
			if texture_present:
				texture_present.visible = true
		TimeComponent.TimePeriod.FUTURE:
			if texture_future:
				texture_future.visible = true
