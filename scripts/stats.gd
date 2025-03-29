class_name Stats
extends Node

# 信号定义
signal health_changed  # 当生命值变化时触发
signal energy_changed  # 当能量值变化时触发

# 导出变量
@export var max_health: int = 5  # 最大生命值
@export var max_energy: float = 10  # 最大能量值
@export var energy_regen: float = 0.8  # 能量恢复速率(每秒)

# 生命值属性，带有setter方法
@onready var health: int = max_health:
    set(v):
        # 确保生命值在0到max_health之间
        v = clampi(v, 0, max_health)
        # 如果值没有变化则直接返回
        if health == v:
            return
        # 更新生命值并发出变化信号
        health = v
        health_changed.emit()

# 能量值属性，带有setter方法
@onready var energy: float = max_energy:
    set(v):
        # 确保能量值在0到max_energy之间
        v = clampf(v, 0, max_energy)
        # 如果值没有变化则直接返回
        if energy == v:
            return
        # 更新能量值并发出变化信号
        energy = v
        energy_changed.emit()


# 每帧调用，处理能量恢复
func _process(delta: float) -> void:
    # 根据恢复速率增加能量值
    energy += energy_regen * delta


# 将状态数据转换为字典格式
func to_dict() -> Dictionary:
    return {
        max_energy=max_energy,  # 包含最大能量值
        max_health=max_health,  # 包含最大生命值
        health=health,  # 包含当前生命值
    }


# 从字典加载状态数据
func from_dict(dict: Dictionary) -> void:
    # 设置最大能量值
    max_energy = dict.max_energy
    # 设置最大生命值
    max_health = dict.max_health
    # 设置当前生命值
    health = dict.health
