extends Area3D
class_name EnemyTorn

@export var path_follow: PathFollow3D
var timer: SceneTreeTimer

const SPEED = .1

func _ready():
	assert(path_follow != null, "Il faut un path_follow")
	visible = false
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

	# Add viewport-based censorship component for PAST time period
	var censor_component = NPCCensorViewportComponent.new()
	censor_component.target_npc = self
	censor_component.viewport_resolution = 128  # Small resolution for performance
	censor_component.pixel_size = 12.0  # Large pixels for heavy censorship
	censor_component.dither_threshold = 0.5  # Dithering amount
	censor_component.overflow_scale = 1.3  # Pixels overflow 30% beyond mesh
	add_child(censor_component)

func _physics_process(delta):
	path_follow.progress_ratio += SPEED * delta

func _on_time_period_changed(new_time_period: TimeComponent.TimePeriod) -> void:
	if timer:
		timer.timeout.disconnect(_on_timeout)
	visible = true
	timer = get_tree().create_timer(1.0)
	timer.timeout.connect(_on_timeout)

func _on_timeout():
	visible = false

func _on_body_entered(body):
	if body is Player:
		body.hit()
