extends "res://global/scenes.gd"

var current_location: int = 0 # 存储当前位置
var visited_locations: Array = [] # 访问过的
var paths: Array = [
	null,
	"res://scenes/explore/treasure/treasure_1.tscn",
	"res://scenes/explore/treasure/treasure_2.tscn",
	"res://scenes/explore/treasure/treasure_3.tscn",
	"res://scenes/explore/treasure/treasure_4.tscn",
	"res://scenes/explore/treasure/treasure_5.tscn",
	"res://scenes/explore/treasure/treasure_6.tscn",
	"res://scenes/explore/battle/inherit/battle_1.tscn",
	"res://scenes/explore/battle/inherit/battle_2.tscn",
	"res://scenes/explore/battle/inherit/battle_3.tscn",
	"res://scenes/explore/battle/inherit/battle_4.tscn",
	"res://scenes/explore/battle/inherit/battle_1.tscn",
	"res://scenes/explore/battle/inherit/battle_2.tscn",
	"res://scenes/explore/battle/inherit/battle_3.tscn",
	"res://scenes/explore/battle/inherit/battle_4.tscn",
	"res://scenes/explore/battle/inherit/battle_1.tscn"
] # 存储下一个场景路径

@onready var space_line: Node = $SpaceLine
@onready var config: Control = $Config/Panel
@onready var color_rect: Control = $Config/ColorRect
@onready var task_list: Control = $TaskList/Panel
@onready var task: Control = $Task
@onready var setting: Control = $Setting
@onready var vigor: Control = $TaskList/Panel/ScrollContainer/VBoxContainer/HBoxContainer6/vigor
@onready var end_explore: Control = $EndExplore/Panel

@export var bgm: AudioStream


func _ready():
	# 播放音乐
	SoundManager.play_bgm(bgm)
	# 读取精神值
	vigor.text = "%d/%d" % [Player.current_vigor, Player.max_vigor]
	# 更新当前位置 已访问星系
	current_location = GalaxyVar.current_location
	visited_locations = GalaxyVar.visited_locations
	# 显示当前位置
	_point_out_current_location(current_location)
	# 暗化已经访问过的星系
	_update_location_visuals()
	# 连接信号
	add_signals()
	# 结束
	if len(visited_locations) == 15:
		var timer = get_tree().create_timer(1)
		await timer.timeout
		
		for node in get_children():
			if node is InterGalaxy:
				node.hide()
		end_explore.show()
		color_rect.hide()
		setting.hide()
		task.hide()


func _process(delta: float) -> void:
	_line_to_mouse(get_viewport().get_mouse_position())


func _point_out_current_location(current_location: int) -> void:
	var node: Node = _get_current_location_node(current_location)
	node.get_node("PointLight2D").show()


func _get_current_location_node(current_location) -> Node:
	# 获取当前current_location对应的节点
	for node in get_children():
		if node.name == "InterGalaxy" + str(current_location):
			return node
	return null


func _line_to_mouse(position: Vector2) -> void:
	if position.y < 210 or position.y > 810 or position.x < 512 or position.x > 1274:
		space_line.hide()
		return
	
	# 显示当前所在星系与鼠标之间的连线
	var begin: Vector2 = _get_current_location_node(current_location).position
	var end = position
	space_line.show()
	space_line.points = [begin, end]


func add_signals() -> void:
	# 添加每个 InterGalaxy 节点的信号连接
	for node in get_children():
		if node is InterGalaxy:
			node.connect("interact", Callable(self, "_on_location_interact"))


func _on_location_interact() -> void:
	# 处理点击事件
	# 获取交互节点
	var interacted_node = get_node_at_input(get_viewport().get_mouse_position())
	if interacted_node is InterGalaxy:
		# 音效
		SoundManager.play_sound_effect("click")
		var location_number = interacted_node.get("number")
		
		if location_number == current_location or location_number in visited_locations:
			# 当前地点或已访问地点，什么都不做
			return

		# 将上一个地点标记为已访问
		visited_locations.append(current_location)
		# 传递给全局变量
		GalaxyVar.visited_locations = visited_locations
		
		# 切换到新场景
		var path: String = paths[location_number]
		SceneChanger.change_scenes(path)
		
		# 更新当前地点
		current_location = location_number
		# 更新全局变量
		GalaxyVar.current_location = location_number


func get_node_at_input(position: Vector2) -> Node:
	# 根据鼠标点击位置获取节点
	for node in get_children():
		if node is InterGalaxy:
			var collision_shape = node.get_node("CollisionShape2D")
			if collision_shape:
				var shape = collision_shape.shape
				var global_transform = node.get_global_transform()
				var circle_radius = shape.radius * 0.15 # InterGalaxy类缩小倍数
				var circle_center = global_transform.origin
				if position.distance_to(circle_center) <= circle_radius:
					return node
	return null


func _update_location_visuals() -> void:
	# 更新星系可见度
	for number in visited_locations:
		var location_node = get_node("InterGalaxy" + str(number))
		if location_node:
			location_node.modulate = Color(0.3, 0.3, 0.3) 


func _on_setting_pressed() -> void:
	SoundManager.play_sound_effect("click")
	config.show()
	color_rect.show()
	
	setting.hide()
	task.hide()
	for node in get_children():
		if node is InterGalaxy:
			node.hide()


func _on_close_setting_pressed() -> void:
	SoundManager.play_sound_effect("click")
	config.hide()
	color_rect.hide()
	
	setting.show()
	task.show()
	for node in get_children():
		if node is InterGalaxy:
			node.show()


func _on_task_pressed() -> void:
	SoundManager.play_sound_effect("click")
	task_list.show()
	color_rect.show()
	
	setting.hide()
	task.hide()
	for node in get_children():
		if node is InterGalaxy:
			node.hide()


func _on_close_task_pressed() -> void:
	SoundManager.play_sound_effect("click")
	task_list.hide()
	color_rect.hide()
	
	setting.show()
	task.show()
	for node in get_children():
		if node is InterGalaxy:
			node.show()


func _on_back_title_pressed() -> void:
	SceneChanger.change_scenes("res://scenes/start/start.tscn")


func _on_back_quit_pressed() -> void:
	get_tree().quit()
