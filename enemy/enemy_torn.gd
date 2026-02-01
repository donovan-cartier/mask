extends Area3D
class_name EnemyTorn

@export var path_follow: PathFollow3D
var timer: SceneTreeTimer

const SPEED = .01

func _ready():
	assert(path_follow != null, "Il faut un path_follow")
	visible = false
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

func _physics_process(delta):
	path_follow.progress_ratio += SPEED * delta

func _on_time_period_changed(_new_time_period: TimeComponent.TimePeriod) -> void:
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
