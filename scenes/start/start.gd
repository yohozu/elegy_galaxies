extends "res://global/scenes.gd"

@export var bgm: AudioStream

@onready var panel: Control = $Config/Panel
@onready var color_rect: Control = $Config/ColorRect
@onready var vbox_container: Control = $VBoxContainer
@onready var end: Control = $End


func _ready() -> void:
	# 初始化数据
	GalaxyVar.current_location = 0
	GalaxyVar.visited_locations = []
	Player.current_vigor = Player.max_vigor
	print(Player.current_vigor)
	
	# bgm播放
	SoundManager.play_bgm(bgm)


func _on_end_pressed() -> void:
	get_tree().quit()


func _on_close_setting_pressed() -> void:
	SoundManager.play_sound_effect("click")
	panel.hide()
	color_rect.hide()
	end.show()
	vbox_container.show()


func _on_start_pressed() -> void:
	SoundManager.play_sound_effect("click")
	SceneChanger.change_scenes("res://scenes/text/text.tscn")


func _on_config_pressed() -> void:
	SoundManager.play_sound_effect("click")
	panel.show()
	color_rect.show()
	vbox_container.hide()
	end.hide()
