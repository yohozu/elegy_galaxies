extends CanvasLayer

@onready var animation: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	self.hide()


func change_scenes(path: String) -> void:
	self.show()
	self.set_layer(99)
	animation.play("changer")
	await animation.animation_finished
	get_tree().change_scene_to_file(path)
	animation.play_backwards("changer")
	await animation.animation_finished
	self.set_layer(-1)
	self.hide()
