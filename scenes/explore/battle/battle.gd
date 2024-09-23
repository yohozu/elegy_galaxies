extends Control

signal text_closed

@onready var text: Control = $Text
@onready var player_container: Control = $PlayerContainer
@onready var sync: Control = $EnemyContainer/Sync
@onready var conn: Control = $EnemyContainer/Conn
@onready var vigor: Control = $PlayerContainer/PlayerPanel/PlayerData/Vigor
@onready var enemy_texture: Control = $EnemyContainer/Enemy
@onready var background: Control = $Background
@onready var anime: Node = $Anime
@onready var anime_1: Node = $Anime1
@onready var anime_2: Node = $Anime2
@onready var anime_3: Node = $Anime3
@onready var anime_4: Node = $Anime4
@onready var skill_number_label: Control = $PlayerContainer/PlayerPanel/PlayerData/SkillNumberLabel
@onready var skill_1: Control = $PlayerContainer/ActionPanel/Actions/Skill1
@onready var skill_2: Control = $PlayerContainer/ActionPanel/Actions/Skill2
@onready var skill_3: Control = $PlayerContainer/ActionPanel/Actions/Skill3
@onready var skill_4: Control = $PlayerContainer/ActionPanel/Actions/Skill4
@onready var end: Control = $PlayerContainer/PlayerPanel/PlayerData/End
@onready var point_light_2d: Node = $PointLight2D
@onready var tips: Control = $Tips
@onready var battle_tips: Control = $BattleTips/ColorRect

@export var enemy: Resource
@export var bgm: AudioStream

var current_vigor: float = 0.0 # 当前玩家精神值
var current_sync: float = 0.0 # 与当前生物同步率
var current_conn: float = 0.0 # 与当前生物连接率
var skill_number: int = Player.energy_number # 回合点数


func _ready() -> void:
	# 音乐
	SoundManager.play_bgm(bgm)
	# 设置所有的血条
	set_value(sync, enemy.current_sync, 100.0, "同步率")
	set_value(conn, enemy.current_conn, 100.0, "连接率")
	set_value(vigor, Player.current_vigor, Player.max_vigor, "精神值")
	# 设置敌人图像和栖息地
	enemy_texture.texture = enemy.texture
	background.texture = enemy.envir
	
	# 最初只显示文本框
	player_container.hide()
	sync.hide()
	conn.hide()
	text.hide()
	tips.hide()
	display_text(enemy.text)
	await text_closed


func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and text.visible:
		# 延时防误触
		var timer = get_tree().create_timer(0.25)
		await timer.timeout
		
		text.hide()
		sync.show()
		conn.show()
		player_container.show()
		tips.show()
		emit_signal("text_closed")


func display_text(contain: String) -> void:
	player_container.hide()
	tips.hide()
	# 显示Label文本
	text.text = contain
	text.show()


func set_value(progress_bar: Control, value: float, max_value: float, type: String) -> void:
	# 初始进度条数值运算
	progress_bar.value = value
	progress_bar.max_value = max_value
	progress_bar.get_node("Label").text = type + ":  %d/%d" % [value, max_value]
	if max_value == 100.0:
		progress_bar.get_node("Label").text = type + ":  %d/%d" % [value, max_value] + "%"


func set_bar_change(progress_bar: Control, value: float, type: String) -> void:
	var max_value: float = progress_bar.max_value
	# 受到攻击后的bar的改变
	if type == "连接率" or type == "同步率":
		progress_bar.get_node("Label").text = type + ":  %d/%d" % [value, max_value] + "%"
	elif type == "精神值":
		progress_bar.get_node("Label").text = type + ":  %d/%d" % [value, max_value]


func check_skill_number(number: int) -> void:
	# 更改文本
	skill_number_label.text = "回合点数: %s" % str(number)


func _on_skill_1_pressed() -> void:
	preventing_multiple_triggers(skill_1)
	
	var number: int = 1 # 技能点数
	var remain_number: int = skill_number - number
	#preventing_multiple_triggers(skill_1)
	if remain_number >= 0:
		# 技能1
		display_text("你搜寻着该生物的意识......")
		await text_closed
	
		conn.value = clamp(Player.damage + conn.value, 0.0, 100.0)
		set_bar_change(conn, conn.value, "连接率")
		
		# 连接动画 有未知bug！！！
		#point_light_2d.show()
		#play_anime(anime, "connect")
		# 音效
		SoundManager.play_sound_effect("slash")
		#anime.play("connect")
		#await anime.animation_finished
		#point_light_2d.hide()
		
		skill_number = remain_number
		check_skill_number(skill_number)

	else:
		return


func _on_skill_2_pressed() -> void:
	preventing_multiple_triggers(skill_2)
	
	var number: int = 2 # 技能点数
	var remain_number: int = skill_number - number

	if remain_number >= 0:
		# 技能2 连接率满足条件才能成功
		if conn.value < 40.0:
			display_text("连接率不足，无法潜入该生物更深层的意识！")
			await text_closed
			
			skill_number = remain_number
			check_skill_number(skill_number)
			
		else:
			display_text("你潜入该生物更深层的意识......")
			await text_closed
			
			# 添加额外伤害和伤害倍率
			var bonus: float = float(floor((conn.value - 40) / 12))
			var multiply: float = 1.1
			Player.multiply = Player.multiply * multiply
			sync.value = clamp(Player.damage * Player.multiply + sync.value + bonus, 0.0, 100.0)
			set_bar_change(sync, sync.value, "同步率")
	
			# 根据敌人编号载入侵入动画
			SoundManager.play_sound_effect("slash")
			match_enemy_anime(enemy.enemy_number, "enemy_damaged")
			
			skill_number = remain_number
			check_skill_number(skill_number)
			
			# 同步率是否达到了100%
			if sync.value == 100.0:
				battle_victory(enemy.enemy_number)
		
	else:
		pass


func _on_skill_3_pressed() -> void:
	preventing_multiple_triggers(skill_3)
	
	var number: int = 1 # 技能点数
	var remain_number: int = skill_number - number
	if remain_number >= 0:
		# 技能3 连接率满足条件才能成功
		if conn.value < 40.0:
			display_text("连接率不足，无法潜入该生物更深层的意识！")
			await text_closed
			
			skill_number = remain_number
			check_skill_number(skill_number)
		else:
			display_text("你将你的意识与该生物的意识缠绕在一起。")
			await text_closed
			
			var bonus: float = float(floor((conn.value - 40) / 12))
			sync.value = clamp(Player.damage * Player.multiply + sync.value + bonus, 0.0, 100.0)
			set_bar_change(sync, sync.value, "同步率")
		
			# 侵入动画
			SoundManager.play_sound_effect("slash")
			match_enemy_anime(enemy.enemy_number, "enemy_damaged")
		
			skill_number = remain_number
			check_skill_number(skill_number)
			
			# 同步率是否达到了100%
			if sync.value == 100.0:
				battle_victory(enemy.enemy_number)


func _on_skill_4_pressed() -> void:
	preventing_multiple_triggers(skill_4)
	
	var number: int = 1 # 技能点数
	var remain_number: int = skill_number - number
	if remain_number >= 0:
		# 技能4
		SoundManager.play_sound_effect("recover")
		display_text("你关闭了自己的心灵，并感到舒适。")
		await text_closed
		
		vigor.value = clamp(vigor.value + Player.recover, 0.0, vigor.max_value)
		set_bar_change(vigor, vigor.value, "精神值")
		
		skill_number = remain_number
		check_skill_number(skill_number)


func preventing_multiple_triggers(name_control: Control) -> void:
	# 防止多次触发
	name_control.disabled = true
	var timer0 = get_tree().create_timer(0.3)
	await timer0.timeout
	name_control.disabled = false


func _on_end_pressed() -> void:
	preventing_multiple_triggers(end)
	SoundManager.play_sound_effect("click")
	
	# 结束回合
	new_turn()
	# 新回合轮到其他生物了
	enemy_turn(enemy.enemy_number)


func enemy_turn(enemy_number: int) -> void:
	match enemy_number:
		1:
			enemy_1_turn()
		2:
			enemy_2_turn()
		3:
			enemy_3_turn()
		4:
			enemy_4_turn()


func enemy_1_turn() -> void:
	var enemy_skill = choose_skill_1()
	match enemy_skill:
		1:
			# 类章鱼生物技能1 降低连接率10%
			display_text("海底生物想要切断你的连接(连接率-10%)。")
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("whoosh")
			play_anime(anime, "shake")
			
			conn.value = clamp(conn.value - enemy.recover_conn, 0.0, 100.0)
			set_bar_change(conn, conn.value, "连接率")
		2:
			# 类章鱼生物技能2 伤害2点精神值
			display_text("海底生物攻击了你的心灵，你感到痛苦(精神值-2)。")
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("whoosh")
			play_anime(anime, "shake")
			
			vigor.value = clamp(vigor.value - enemy.damage, 0.0, vigor.max_value)
			set_bar_change(vigor, vigor.value, "精神值")
			
			# 判断玩家精神值是否归零
			if vigor.value == 0.0:
				battle_failed()
		3:
			# 类章鱼生物技能3 同步率下降10%
			display_text("海底生物拒绝与你的心灵同步(同步率-10%)。")
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("whoosh")
			play_anime(anime, "shake")
			
			sync.value = clamp(sync.value - enemy.recover_sync, 0.0, 100.0)
			set_bar_change(sync, sync.value, "同步率")


func enemy_2_turn() -> void:
	# 气体生物每回合buff 随气流运动
	var percentage: float = randf()
	if percentage > 0.2:
		display_text("你感觉该生物的意识随着气流在运动，难以捕捉(连接率-10%)。")
		await text_closed
		
		conn.value = clamp(conn.value - enemy.recover_conn, 0.0, 100.0)
		set_bar_change(conn, conn.value, "连接率")
		
		# 简单延时
		player_container.hide()
		var timer = get_tree().create_timer(0.1)
		await timer.timeout
		player_container.show()

	var enemy_skill = choose_skill_2()
	match enemy_skill:
		1:
			# 气体生物技能1 降低同步率10%
			display_text("气体生物拒绝与你的心灵同步(同步率-10%)。")
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("whoosh")
			play_anime(anime, "shake")
			
			sync.value = clamp(sync.value - enemy.recover_sync, 0.0, 100.0)
			set_bar_change(sync, sync.value, "同步率")
		2:
			# 气体生物技能2 伤害3点精神值
			display_text("气体生物攻击了你的心灵，你感到痛苦(精神值-3)。")
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("whoosh")
			play_anime(anime, "shake")
			
			vigor.value = clamp(vigor.value - enemy.damage, 0.0, vigor.max_value)
			set_bar_change(vigor, vigor.value, "精神值")
			
			# 判断玩家精神值是否归零
			if vigor.value == 0.0:
				battle_failed()


func enemy_3_turn() -> void:
	# 陆地生物每回合buff 防御＋进攻
	var percentage: float = randf()
	if percentage > 0.2:
		display_text("该生物抵抗你的意识侵入并进行反击(同步率-10%%，精神值-%d)。" % round(enemy.multiply_damage))
		await text_closed
		
		sync.value = clamp(sync.value - 10.0, 0.0, 100.0)
		set_bar_change(sync, sync.value, "同步率")
		vigor.value = clamp(vigor.value - enemy.multiply_damage, 0.0, vigor.max_value)
		set_bar_change(vigor, vigor.value, "精神值")
		
		if vigor.value == 0.0:
			battle_failed()
		
		# 简单延时
		player_container.hide()
		var timer = get_tree().create_timer(0.1)
		await timer.timeout
		player_container.show()
		
	var enemy_skill = choose_skill_3()
	match enemy_skill:
		1:
			# 陆地生物技能1 降低同步率15%
			display_text("陆地生物拒绝与你的心灵同步(同步率-15%)。")
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("whoosh")
			play_anime(anime, "shake")
			
			sync.value = clamp(sync.value - enemy.recover_sync, 0.0, 100.0)
			set_bar_change(sync, sync.value, "同步率")
		2:
			# 陆地生物技能2 伤害2点精神值
			display_text("陆地生物攻击了你的心灵，你感到痛苦(精神值-%d)。" % round(enemy.damage * enemy.multiply_damage))
			
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("whoosh")
			play_anime(anime, "shake")
			
			var total_damage: float = enemy.damage * enemy.multiply_damage
			vigor.value = clamp(vigor.value - total_damage, 0.0, vigor.max_value)
			set_bar_change(vigor, vigor.value, "精神值")
			
			# 判断玩家精神值是否归零
			if vigor.value == 0.0:
				battle_failed()
		3:
			# 陆地生物技能3 增加伤害倍率
			display_text("陆地生物强化了自己的精神(精神伤害加成10%)。")
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("energy")
			point_light_2d.show()
			anime.play("strength")
			await anime.animation_finished
			point_light_2d.hide()
			
			enemy.multiply_damage = 1.1 * enemy.multiply_damage


func enemy_4_turn() -> void:
	var enemy_skill = choose_skill_4()
	match enemy_skill:
		1:
			# 浮游生物技能1 降低连接率5%
			display_text("浮游生物想要切断你的连接(连接率-5%)。")
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("whoosh")
			play_anime(anime, "shake")
			
			conn.value = clamp(conn.value - enemy.recover_conn, 0.0, 100.0)
			set_bar_change(conn, conn.value, "连接率")
		2:
			# 浮游生物技能2 伤害4点精神值
			display_text("浮游生物攻击了你的心灵，你感到痛苦(精神值-4)。")
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("whoosh")
			play_anime(anime, "shake")
			
			vigor.value = clamp(vigor.value - enemy.damage, 0.0, vigor.max_value)
			set_bar_change(vigor, vigor.value, "精神值")
			
			# 判断玩家精神值是否归零
			if vigor.value == 0.0:
				battle_failed()
		3:
			# 浮游生物技能3 使玩家回合点数-1
			display_text("浮游生物想要挣脱你的操纵，你的意识分散了(下回合点数-1)。")
			await text_closed
			
			# 侵入动画
			SoundManager.play_sound_effect("whoosh")
			play_anime(anime, "shake")
			
			skill_number = skill_number - 1
			skill_number_label.text = "回合点数: %s" % str(skill_number)


func choose_skill_1() -> int:
	# 根据权重选择技能
	var random_value: float = randf()  # 获取0到1之间的随机浮点数
	if random_value < 0.4: # 连接率下降
		return 1
	elif random_value < 0.6: # 精神值下降
		return 2
	else: # 同步率下降
		return 3


func choose_skill_2() -> int:
	# 根据权重选择技能
	var random_value: float = randf()  # 获取0到1之间的随机浮点数
	if random_value < 0.6: # 同步率下降
		return 1
	else: # 精神值下降
		return 2


func choose_skill_3() -> int:
	# 根据权重选择技能
	var random_value: float = randf()  # 获取0到1之间的随机浮点数
	if random_value < 0.4: # 同步率降低
		return 1
	elif random_value < 0.7: # 精神攻击
		return 2
	else: # 攻击倍率上升
		return 3


func choose_skill_4() -> int:
	# 根据权重选择技能
	var random_value: float = randf()  # 获取0到1之间的随机浮点数
	if random_value < 0.35:
		return 1
	elif random_value < 0.7:
		return 2
	else:
		return 3


func battle_failed() -> void:
	player_container.hide()
	
	display_text("其他生物的意识逐渐填充了你的心灵。")
	SoundManager.play_sound_effect("glass")
	await text_closed
	display_text("你感到非常困倦，意识不知不觉间飘向了宇宙深处......")
	await text_closed
	
	# 延时
	if text.visible == false:
		sync.hide()
		conn.hide()
		player_container.hide()
		tips.hide()
		
		var timer = get_tree().create_timer(1)
		await timer.timeout
		SceneChanger.change_scenes("res://scenes/start/start.tscn")


func save_return() -> void:
	# 保存当前的玩家精神值以及清空攻击倍率
	Player.current_vigor = vigor.value
	Player.multiply = 1.0


func play_anime(anime: AnimationPlayer, anime_name: String) -> void:
	# 播放动画
	anime.play(anime_name)
	await anime.animation_finished


func battle_victory(enemy_number: int) -> void:
	# 保存和重置玩家数据
	save_return()
	
	player_container.hide()
	
	match_enemy_anime(enemy_number, "invasion")
	SoundManager.play_sound_effect("up")
	
	display_text("侵入成功！")
	await text_closed
	
	display_text("很遗憾，该生物的意识中没有关于宇宙之神的信息。")
	await text_closed
	
	# 延时
	if text.visible == false:
		sync.hide()
		conn.hide()
		player_container.hide()
		tips.hide()
		
		var timer = get_tree().create_timer(1)
		await timer.timeout
		SceneChanger.change_scenes("res://scenes/galaxy/intergalactic.tscn")


func match_enemy_anime(enemy_number: int, anime_name: String) -> void:
	# 匹配敌人动画
	match enemy_number:
		1:
			play_anime(anime_1, anime_name)
		2:
			play_anime(anime_2, anime_name)
		3:
			play_anime(anime_3, anime_name)
		4:
			play_anime(anime_4, anime_name)


func new_turn() -> void:
	# 新回合
	skill_number = 2
	skill_number_label.text = "回合点数: %s" % str(skill_number)


func _on_close_tips_pressed() -> void:
	SoundManager.play_sound_effect("click")
	battle_tips.hide()


func _on_tips_pressed() -> void:
	SoundManager.play_sound_effect("click")
	battle_tips.show()
