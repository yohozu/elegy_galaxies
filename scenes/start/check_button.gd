extends CheckButton

var is_full: bool = false

func _on_pressed() -> void:
	SoundManager.play_sound_effect("click")
	
	if is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	is_full = !is_full


func _on_on_3_pressed() -> void:
	SoundManager.se_on = true


func _on_off_3_pressed() -> void:
	SoundManager.se_on = false
