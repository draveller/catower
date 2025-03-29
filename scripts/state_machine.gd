class_name StateMachine
extends Node

# 特殊常量，表示保持当前状态不变
const KEEP_CURRENT := -1

# 当前状态索引，设置时会触发状态转换
var current_state: int = -1:
    set(v):
        # 调用所有者的状态转换处理函数
        owner.transition_state(current_state, v)
        # 更新当前状态
        current_state = v
        # 重置状态计时器
        state_time = 0

# 记录当前状态持续时间(秒)
var state_time: float


# 节点准备就绪时初始化状态机
func _ready() -> void:
    # 等待所有者节点准备就绪
    await owner.ready
    # 设置初始状态(通常为0)
    current_state = 0


# 物理处理循环，每帧调用
func _physics_process(delta: float) -> void:
    # 状态转换循环，直到状态稳定
    while true:
        # 从所有者获取下一个状态
        var next := owner.get_next_state(current_state) as int
        # 如果返回KEEP_CURRENT，则保持当前状态
        if next == KEEP_CURRENT:
            break
        # 否则转换到新状态(会触发setter)
        current_state = next

    # 调用所有者的物理状态更新函数
    owner.tick_physics(current_state, delta)
    # 更新状态持续时间
    state_time += delta
