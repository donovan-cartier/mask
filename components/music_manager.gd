extends Node
class_name MusicManager

@export var audio_stream_player: AudioStreamPlayer
@export var past_music: AudioStream
@export var present_music: AudioStream
@export var future_music: AudioStream

var latest_song_position : float = 0.0

func _ready():
	_set_audio_stream()
	Nodes.player.changed_time_period.connect(_on_time_period_changed)

func _set_audio_stream() -> void:
	match Nodes.player.current_time_period:
		TimeComponent.TimePeriod.PAST:
			audio_stream_player.stream = past_music
		TimeComponent.TimePeriod.PRESENT:
			audio_stream_player.stream = present_music
		TimeComponent.TimePeriod.FUTURE:
			audio_stream_player.stream = future_music

	audio_stream_player.play()

func _on_time_period_changed(new_time_period: TimeComponent.TimePeriod) -> void:
	if audio_stream_player.stream:
		latest_song_position = audio_stream_player.get_playback_position()
	_set_audio_stream()
	audio_stream_player.seek(latest_song_position)