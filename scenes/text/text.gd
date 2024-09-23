extends "res://global/scenes.gd"

var describe: Array = [
	"暗无天日的混沌之中，意识归于虚无。肉体化为一摊脓水，蒸腾消失。你如同沉眠于深海里的一块岩石，无意识地存在着。",
	"不知跨越了多少漫长的世纪。某日，光芒渗透到海洋深处，你感觉周围越来越明亮。虚无瓦解，意识凝结成实体附着于躯体，重现于世。",
	"晃荡的视野逐渐稳定，眼前的图像变得清晰，你身处一艘小型星舰的驾驶舱中。内置的探测仪显示外星体上无其他生命存在。",
	"储存的记忆支离破碎，你已无从知晓自己的过去。你在星舰系统中发现一条指令：“寻找宇宙之神”。这让你振奋起来，决心踏上旅程。",
	"开始入侵......"
]
var index: int = 0

@onready var label = $Label
@onready var left_arrow = $LeftArrow
@onready var right_arrow = $RightArrow
@onready var color_rect = $ColorRect
@onready var pic0 = $Pic0
@onready var pic1 = $Pic1
@onready var pic2 = $Pic2
@onready var pic3 = $Pic3
@onready var pic4 = $Pic4
@onready var pics: Array = [pic0, pic1, pic2, pic3, pic4]


func _ready() -> void:
	# 随着场景运行初始化index以及隐藏左箭头
	index = 0
	left_arrow.hide()
	label.text = describe[index]
	pics[index].show()


func _on_right_i_interact() -> void:
	SoundManager.play_sound_effect("click")
	# 延时
	var timer0 = get_tree().create_timer(0.4)
	await timer0.timeout
	pics[index].hide()
	index += 1
	
	left_arrow.show()
	if index == 5:
		SceneChanger.change_scenes("res://scenes/galaxy/intergalactic.tscn")
	else:
		label.text = describe[index]
		pics[index].show()


func _on_left_i_interact() -> void:
	SoundManager.play_sound_effect("click")
	# 延时
	var timer0 = get_tree().create_timer(0.4)
	await timer0.timeout
	
	pics[index].hide()
	index -= 1

	label.text = describe[index]
	pics[index].show()
	if index == 0:
		left_arrow.hide()
