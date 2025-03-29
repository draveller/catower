class_name Monster
extends CharacterBody2D

# 方向枚举
enum Direction {LEFT = -1, RIGHT = +1}

# 信号定义
signal died # 死亡时触发

# 基础属性分组
@export_group("基础属性")
# 贴图的头部朝向
@export var texture_facing := Direction.RIGHT
# 敌人当前方向，设置时会自动更新图形朝向
@export var direction := Direction.RIGHT
# 最大移动速度
@export var max_speed := 180.0
# 击退力度
@export var knockback_power := 512.0
# 节点引用
@onready var graphics: Node2D = $Graphics # 图形节点
@onready var animation_player: AnimationPlayer = $AnimationPlayer # 动画播放器
@onready var state_machine: Node = $StateMachine # 状态机
@onready var stats: Node = $Stats # 状态属性
@onready var hitbox: Hitbox = $Graphics/Hitbox
@onready var hurtbox: Hurtbox = $Graphics/Hurtbox

# 获取项目设置中的默认重力值
var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float

# 加速度
const ACCELERATION := 2000

func _ready() -> void:
    if texture_facing != direction:
         graphics.scale.x = - graphics.scale.x

    var is_left_team := direction == Direction.RIGHT
    if is_left_team:
        set_collision_layer_value(LayerConst.LEFT_TEAM_MONSTER, true)
        set_collision_mask_value(LayerConst.RIGHT_TEAM_MONSTER, true)
        set_collision_mask_value(LayerConst.RIGHT_TEAM_TOWER, true)
        hitbox.set_collision_mask_value(LayerConst.RIGHT_TEAM_MONSTER, true)
        hurtbox.set_collision_layer_value(LayerConst.LEFT_TEAM_MONSTER, true)
    else:
        set_collision_layer_value(LayerConst.RIGHT_TEAM_MONSTER, true)
        set_collision_mask_value(LayerConst.LEFT_TEAM_MONSTER, true)
        set_collision_mask_value(LayerConst.LEFT_TEAM_TOWER, true)
        hitbox.set_collision_mask_value(LayerConst.LEFT_TEAM_MONSTER, true)
        hurtbox.set_collision_layer_value(LayerConst.RIGHT_TEAM_MONSTER, true)

    set_collision_mask_value(LayerConst.GROUND, true)


# 移动函数
func move(speed: float, delta: float) -> void:
    # 水平移动插值
    velocity.x = move_toward(velocity.x, speed * direction, ACCELERATION * delta)
    # 应用重力
    velocity.y += default_gravity * delta
    # 执行移动
    move_and_slide()

# 死亡函数
func die() -> void:
    died.emit() # 发出死亡信号
    queue_free() # 释放节点
