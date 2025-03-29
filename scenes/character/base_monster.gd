class_name BaseMonster
extends CharacterBody2D

# 基础属性
@export_group("基础属性")
@export var team: String = "left" # 队伍名称, 怪物会攻击非同队的怪物
@export var max_health: float = 100.0 # 最大生命值
@export var attack_power: float = 20.0 # 攻击力
@export var move_speed: float = 50.0 # 移动速度
@export var texture_facing: int = 1 # 贴图静态朝向, -1表示向左, 1表示向右

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var attack_area: Area2D = $AttackArea
@onready var hurt_area: Area2D = $HurtArea
@onready var invincible_timer: Timer = $InvincibleTimer

# 状态变量
var current_health: float # 当前生命值
# 物理常量
const GRAVITY: float = 980.0 # 重力加速度
const FRICTION: float = 1000.0 # 摩擦力值

var mc: MonsterStateMachine
var initial_facing: int

# 初始化函数
func _ready() -> void:
    current_health = max_health
    initial_facing = 1 if team == "left" else -1
    # 根据初始朝向设置节点翻转
    turn_facing()
    # 初始化血量
    health_bar.value = 100.0
    # 初始化状态机
    mc = MonsterStateMachine.new(self)


# 物理处理函数
func _physics_process(delta: float) -> void:
    # 应用重力
    if not is_on_floor():
        velocity.y += GRAVITY * delta
    move_and_slide()
    mc.update(delta)


func turn_facing() -> void:
    if texture_facing != initial_facing:
        sprite.flip_h = true

func idle() -> void:
    sprite.play("idle")

func move() -> void:
    sprite.play("move")
    velocity.x = initial_facing * move_speed

func attack() -> void:
    sprite.play("attack")

func hurt(damage: float) -> void:
    if invincible_timer.get_time_left() > 0:
        return
    sprite.play("hurt")
    current_health = max(current_health - damage, 0)  # 确保血量不低于0
    health_bar.value = (current_health / max_health) * 100  # 转换为百分比

    velocity.x = - initial_facing * 160.0
    velocity.y = -100.0
    invincible_timer.start()

func dead() -> void:
    set_physics_process(false)  # 停止物理处理
    attack_area.monitoring = false  # 停止攻击检测
    hurt_area.monitoring = false  # 停止受伤检测
    sprite.play("dead")
    velocity = Vector2.ZERO
    await sprite.animation_finished  # 等待死亡动画播放完毕
    queue_free()


# 检查是否是敌人
func is_enemy(node: Node) -> bool:
    if node is BaseMonster:
        return node.team and node.team != self.team
    if node is Area2D and node.owner is BaseMonster:
        return node.owner.team and node.owner.team != self.team
    return false
