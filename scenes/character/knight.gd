class_name Knight
extends Monster

# 野猪状态枚举
enum State {
    IDLE, # 空闲状态
    WALK, # 行走状态
    ATTACK, # 攻击状态
    HURT, # 受伤状态
    DYING, # 死亡状态
}

# 待处理的伤害
var pending_damage: Damage

# 节点引用
@onready var enemy_checker: RayCast2D = $Graphics/EnemyChecker # 玩家检测
@onready var health_bar: TextureProgressBar = $HealthBar


func _ready() -> void:
    super._ready()
    if direction == Direction.RIGHT:
        enemy_checker.set_collision_mask_value(LayerConst.RIGHT_TEAM_MONSTER, true)
        enemy_checker.set_collision_mask_value(LayerConst.RIGHT_TEAM_TOWER, true)
    else:
        enemy_checker.set_collision_mask_value(LayerConst.LEFT_TEAM_MONSTER, true)
        enemy_checker.set_collision_mask_value(LayerConst.LEFT_TEAM_TOWER, true)

# 检查是否能看见玩家
func can_attack() -> bool:
    return enemy_checker.is_colliding()

# 物理状态更新
func tick_physics(state: State, delta: float) -> void:
    match state:
        State.IDLE, State.ATTACK, State.HURT, State.DYING:
            move(0.0, delta) # 静止状态不移动

        State.WALK:
            move(max_speed / 3, delta) # 以1/3速度行走

# 获取下一个状态
func get_next_state(state: State) -> int:
    if stats.health == 0: # 生命值为0时进入死亡状态
        return StateMachine.KEEP_CURRENT if state == State.DYING else State.DYING

    if pending_damage: return State.HURT

    match state:
        State.IDLE:
            if state_machine.state_time > 1:
                return State.WALK
        State.WALK:
            if can_attack():
                return State.ATTACK
        State.ATTACK:
            if not animation_player.is_playing():
                return State.WALK
        State.HURT:
            if not animation_player.is_playing(): # 受伤动画播放完后奔跑
                return State.WALK

    return StateMachine.KEEP_CURRENT # 保持当前状态

# 状态转换处理
func transition_state(_from: State, to: State) -> void:
    match to:
        State.IDLE:
            animation_player.play("idle") # 播放空闲动画
        State.WALK:
            animation_player.play("move") # 播放行走动画
        State.ATTACK:
            animation_player.play("attack") # 播放攻击动画
        State.HURT:
            animation_player.play("hurt") # 播放受伤动画
            stats.health -= pending_damage.amount # 扣除生命值
            health_bar.value = stats.health * 100.0 / stats.max_health

            # 计算击退方向
            var dir := pending_damage.source.global_position.direction_to(global_position)
            velocity = dir * knockback_power

            # 根据伤害来源调整朝向
            direction = Direction.LEFT if  dir.x > 0 else Direction.RIGHT
            # 清空待处理伤害
            pending_damage = null

        State.DYING:
            animation_player.play("die") # 播放死亡动画

# 受伤区域被击中时的回调
func _on_hurtbox_hurt(hb: Hitbox) -> void:
    pending_damage = Damage.new() # 创建伤害对象
    pending_damage.amount = 1 # 设置伤害值
    pending_damage.source = hb.owner # 设置伤害来源
