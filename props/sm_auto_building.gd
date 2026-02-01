@tool

extends StaticBody3D
class_name AutoBuilding

# var time_component: TimeComponent
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@export var building: Building
@export var type: TimeComponent.TimePeriod = TimeComponent.TimePeriod.PRESENT
@export var height: float = 10.0
@export_range(0.1, 10.0, .1) var custom_scale: float = 1.0:
	set(value):
		custom_scale = value
		if mesh_instance:
			mesh_instance.scale = Vector3.ONE * custom_scale
		if collision_shape:
			collision_shape.scale = Vector3.ONE * custom_scale

@export var custom_rotation: Vector3 = Vector3.ZERO:
	set(value):
		custom_rotation = value
		if mesh_instance:
			mesh_instance.rotation_degrees = custom_rotation
		if collision_shape:
			collision_shape.rotation_degrees = custom_rotation

@export var mesh_offset: Vector3 = Vector3.ZERO:
	set(value):
		mesh_offset = value
		if mesh_instance:
			mesh_instance.position = mesh_offset

@export_tool_button("Update Building") var update_action = update_building

func _ready():
	if !Engine.is_editor_hint():
		Nodes.player.changed_time_period.connect(update_type)
		type = Nodes.player.current_time_period
		update_building()			

func _process(_delta):
	if Engine.is_editor_hint():
		update_building()

func update_building():
	if !building:
		return
		
	var mesh: Mesh
	var shape: Shape3D

	match type:
		TimeComponent.TimePeriod.PAST:
			mesh = building.past_mesh
			shape = building.past_shape
		TimeComponent.TimePeriod.PRESENT:
			mesh = building.present_mesh
			shape = building.present_shape
		TimeComponent.TimePeriod.FUTURE:
			mesh = building.future_mesh
			shape = building.future_shape

	mesh_instance.mesh = mesh
	collision_shape.shape = shape
	mesh_instance.scale = Vector3.ONE * custom_scale
	collision_shape.scale = Vector3.ONE * custom_scale
	mesh_instance.rotation_degrees = custom_rotation
	collision_shape.rotation_degrees = custom_rotation
	mesh_instance.position = mesh_offset

func update_type(time_period: TimeComponent.TimePeriod):
	type = time_period
	update_building()
