extends "res://global/scenes.gd"

@export var bgm: AudioStream


func _ready() -> void:
	# 播放音乐
	SoundManager.play_bgm(bgm)


func _on_texture_button_pressed() -> void:
	SoundManager.play_sound_effect("click")
	var timer = get_tree().create_timer(0.4)
	await timer.timeout
	SceneChanger.change_scenes("res://scenes/galaxy/intergalactic.tscn")
