extends Node

enum Bus { Master, SE, BGM }

@onready var sound_effect: Node = $SoundEffect
@onready var bgm_player: AudioStreamPlayer = $BGMplayer

var se_on: bool = true


func play_sound_effect(name: String) -> void:
	var player := sound_effect.get_node(name) as AudioStreamPlayer
	if not player:
		return
	if se_on:
		player.play()


func play_bgm(stream: AudioStream) -> void:
	if bgm_player.stream == stream and bgm_player.playing:
		return
	bgm_player.stream = stream
	bgm_player.play()


func get_volume(bus_index: int) -> float:
	var db := AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)


func set_volume(bus_index: int, v) -> void:
	var db = linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index, db)
