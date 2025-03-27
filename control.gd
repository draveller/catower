extends Control

@export var radius: float = 200.0 # 菜单半径
@export var rotation_speed: float = 2.0 # 旋转速度
@export var level_count: int = 7 # 关卡数量
@export var smooth_factor: float = 0.2 # 平滑因子，值越小动画越平滑
@export var auto_rotate_delay: float = 3.0 # 无操作后开始自动旋转的延迟时间（秒）
@export var auto_rotate_speed: float = 0.2 # 自动旋转的速度（弧度/秒）

var current_rotation: float = 0.0
var target_rotation: float = 0.0 # 目标旋转角度
var is_rotating: bool = false
var rotation_container: Node2D
var last_mouse_pos: Vector2
var highlighted_button: TextureButton = null
var is_on_button: bool = false # 新增：标记鼠标是否在按钮上
var last_interaction_time: float = 0.0 # 最后交互时间
var is_auto_rotating: bool = false # 是否正在自动旋转

func _ready() -> void:
    setup_rotation_container()
    create_level_buttons()
    update_buttons_position()
    create_center_point()

func setup_rotation_container() -> void:
    rotation_container = Node2D.new()
    $CenterContainer.add_child(rotation_container)

func create_center_point() -> void:
    var center_point = ColorRect.new()
    center_point.color = Color(1, 1, 1, 0.5)
    center_point.size = Vector2(20, 20)
    center_point.position = Vector2(-10, -10)
    $CenterContainer.add_child(center_point)

func create_level_buttons() -> void:
    for i in range(level_count):
        var button = preload("res://level_button.tscn").instantiate()
        rotation_container.add_child(button)
        button.level_number = i + 1
        button.angle = (2 * PI * i) / level_count
        button.radius = radius
        button.pressed.connect(_on_level_button_pressed.bind(i + 1))

func update_buttons_position() -> void:
    var buttons = get_buttons()
    buttons.sort_custom(func(a, b): return a.angle < b.angle)

    for button in buttons:
        update_button_position(button)
        update_button_highlight(button, buttons)

func get_buttons() -> Array:
    var buttons = []
    for child in rotation_container.get_children():
        if child is TextureButton:
            buttons.append(child)
    return buttons

func update_button_position(button: TextureButton) -> void:
    var new_angle = button.angle + current_rotation
    button.position = Vector2(
        radius * cos(new_angle),
        radius * sin(new_angle)
    )
    button.rotation = 0

func update_button_highlight(button: TextureButton, all_buttons: Array) -> void:
    var is_bottom = is_button_at_bottom(button, all_buttons)

    if is_bottom:
        if highlighted_button != button:
            if highlighted_button:
                highlighted_button.modulate = Color(1, 1, 1, 1)
            button.modulate = Color(1.2, 1.2, 1.2, 1)
            highlighted_button = button
            button.get_parent().remove_child(button)
            rotation_container.add_child(button)
    elif button == highlighted_button:
        button.modulate = Color(1, 1, 1, 1)
        highlighted_button = null

func is_button_at_bottom(button: TextureButton, all_buttons: Array) -> bool:
    for other_button in all_buttons:
        if other_button != button and other_button.position.y > button.position.y:
            return false
    return true

func _input(event: InputEvent) -> void:
    # 更新最后交互时间
    if event is InputEventMouseMotion or event is InputEventMouseButton:
        last_interaction_time = Time.get_ticks_msec() / 1000.0
        is_auto_rotating = false

    if event is InputEventMouseMotion:
        # 检查鼠标是否在任何按钮上
        var mouse_pos = get_local_mouse_position()
        is_on_button = false
        for button in get_buttons():
            if button.get_global_rect().has_point(button.get_global_mouse_position()):
                is_on_button = true
                break

        if event.button_mask == MOUSE_BUTTON_LEFT and is_on_button:
            handle_mouse_motion(event)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
        is_rotating = false
        last_mouse_pos = Vector2.ZERO
        is_on_button = false

func handle_mouse_motion(_event: InputEventMouseMotion) -> void:
    var mouse_pos = get_local_mouse_position()
    var center = $CenterContainer.position

    if last_mouse_pos != Vector2.ZERO:
        var current_angle = (mouse_pos - center).angle()
        var last_angle = (last_mouse_pos - center).angle()
        var angle_diff = current_angle - last_angle

        # 处理角度跨越 180 度的情况
        if angle_diff > PI:
            angle_diff -= 2 * PI
        elif angle_diff < -PI:
            angle_diff += 2 * PI

        # 使用缓动函数计算目标旋转角度
        target_rotation += angle_diff * rotation_speed

    last_mouse_pos = mouse_pos
    is_rotating = true

func _process(delta: float) -> void:
    var current_time = Time.get_ticks_msec() / 1000.0

    # 检查是否需要开始自动旋转
    if not is_rotating and not is_on_button and current_time - last_interaction_time >= auto_rotate_delay:
        is_auto_rotating = true

    if is_rotating:
        # 使用 lerp_angle 实现平滑插值
        current_rotation = lerp_angle(current_rotation, target_rotation, smooth_factor)
        update_buttons_position()
    elif is_auto_rotating:
        # 自动旋转
        target_rotation += auto_rotate_speed * delta
        current_rotation = lerp_angle(current_rotation, target_rotation, smooth_factor)
        update_buttons_position()
    else:
        # 当停止旋转时，确保最终位置精确
        current_rotation = target_rotation
        update_buttons_position()

func _on_level_button_pressed(level: int) -> void:
    print("选择关卡: ", level)
    # 这里添加关卡加载逻辑
