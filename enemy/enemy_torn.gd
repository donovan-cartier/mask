extends CharacterBody3D
class_name EnemyTorn

@export var path_follow: PathFollow3D

var timer: SceneTreeTimer

const SPEED = .1

func _ready():
	assert(path_follow != null, "Il faut un path_follow")
	visible = false
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

func _physics_process(delta):
	path_follow.progress_ratio += SPEED * delta

func _on_time_period_changed(new_time_period: TimeComponent.TimePeriod) -> void:
	visible = true
	timer = get_tree().create_timer(1.0)
	await timer.timeout
	visible = false