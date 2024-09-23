extends Area2D
class_name Interactable

signal interact # 鼠标左键点击可交互对象之后，会发出信号


func _input_event(viewport, event, shape_idx):
	# 如果点击了可交互对象，调用发信号的函数
	if not event.is_action_pressed("interact"):
		return
	_interact()


func _interact():
	emit_signal("interact")
