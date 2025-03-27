class_name MonsterStateMachine
extends Node

# 状态枚举
enum State {
    IDLE, # 空闲状态(仅限出生后的一小会)
    MOVE, # 移动状态
    ATTACK, # 攻击状态
    HURT, # 受伤状态, 在此状态中即为无敌时间
    DEAD, # 死亡状态
}

# 当前状态
var current_state: State = State.IDLE
# 状态机所有者（怪物实例）
var monster: BaseCharacter
# 状态计时器
var state_timer: float = 0.0

# 状态持续时间
var IDLE_TIME := randf_range(0.5, 1.0)
# 无敌时间计时器
var invincible_timer: SceneTreeTimer

# 指示当前是否应该作出攻击行为
var should_attack = false
# 指示当前是否应该作出受伤行为
var is_in_hurt_area = false

## 初始化函数
func _init(monster_instance: BaseCharacter) -> void:
    monster = monster_instance

    # 连接碰撞信号
    monster.attack_area.body_entered.connect(_on_attack_area_body_entered)
    monster.attack_area.body_exited.connect(_on_attack_area_body_exited)
    monster.hurt_area.area_entered.connect(_on_hurt_area_area_entered)
    monster.hurt_area.area_exited.connect(_on_hurt_area_exited)


# 攻击区域检测到敌人进入
func _on_attack_area_body_entered(body: Node2D) -> void:
    if monster.is_enemy(body):
        should_attack = true

# 攻击区域检测到敌人退出
func _on_attack_area_body_exited(body: Node2D) -> void:
    if monster.is_enemy(body):
        should_attack = false

# 受伤区域检测到攻击
func _on_hurt_area_area_entered(area: Area2D) -> void:
    if monster.is_enemy(area) and area.owner.mc.current_state == State.ATTACK:
        is_in_hurt_area = true

func _on_hurt_area_exited(area: Area2D) -> void:
    if monster.is_enemy(area):
        is_in_hurt_area = false

func should_be_hurt() -> bool:
    return is_in_hurt_area and monster.invincible_timer.get_time_left() <= 0


# 状态机更新函数
func update(delta: float) -> void:
    state_timer += delta

    match current_state:
        State.IDLE:
            print("%s: 空闲"%monster.name)
        # 空闲状态下如果经过了一段时间, 就进行移动
            if state_timer >= IDLE_TIME:
                current_state = State.MOVE
                monster.move()
                state_timer = 0.0
        State.MOVE:
            print("%s: 移动"%monster.name)
        # 移动状态下, 持续检测攻击和受击, 并作出相应动作
            if should_be_hurt():
                current_state = State.HURT
                monster.hurt(20)
            if should_attack:
                current_state = State.ATTACK
                monster.attack()
        State.ATTACK:
            print("%s: 攻击"%monster.name)
            if should_be_hurt():
                current_state = State.HURT
                monster.hurt(20)
            elif should_attack and not monster.animated_sprite.is_playing():
                monster.attack()
            elif not should_attack:
                current_state = State.MOVE
                monster.move()
        State.HURT:
            print("%s: 受伤"%monster.name)
            if monster.current_health <= 0:
                current_state = State.DEAD
                return
            if monster.invincible_timer.get_time_left() <= 0:
                current_state = State.MOVE
                monster.move()
        State.DEAD:
            print("%s: 死亡"%monster.name)
            monster.dead()
