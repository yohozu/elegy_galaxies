class_name Scenes
extends Sprite2D


func _ready():
	# 创建补间动画，使得进入新场景有一个画面缩小的效果
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).from(Vector2.ONE * 1.05)
