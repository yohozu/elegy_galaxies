extends Resource

@export var text: String = ""
@export var texture: Texture2D = null
@export var envir: Texture2D = null
@export var damage: float = 0.0 # 伤害玩家精神值
@export var multiply_damage: float = 1 # 攻击倍率
@export var recover_conn: float = 0.0 # 恢复连接率
@export var recover_sync: float = 0.0 # 恢复同步率
@export var current_sync: float = 0.0
@export var current_conn: float = 40.0 # 初始连接率设置为40%
@export var enemy_number: int = 0 # 怪物编号 控制动画
