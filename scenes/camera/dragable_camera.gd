class_name DragableCamera

extends Camera2D

# 边界限制
@export var camera_limit_left:= -1000
@export var camera_limit_right:= 1000
@export var enabled_drag:= false

# 摄像机的缩放系数
var scale_num = 1

# 是否正在拖拽
var is_dragging = false

# 拖拽相关变量
var drag_start_pos: Vector2 = Vector2.ZERO
var camera_start_pos: Vector2 = Vector2.ZERO

# 视口相关
var half_viewport_size: Vector2

func _ready():
    self.zoom = Vector2(scale_num, scale_num)
    half_viewport_size = get_viewport_rect().size / 2
    # 设置相机边界
    self.limit_left = camera_limit_left
    self.limit_right = camera_limit_right
    # 确保初始位置在有效范围内
    _clamp_camera_position()
    SignalBus.connect("battle_entered", _on_battle_entered)


func _input(event: InputEvent) -> void:
    if not enabled_drag:
        return
    if event is InputEventMouseButton:
        match event.button_index:
            MOUSE_BUTTON_WHEEL_DOWN:
                var old_scale = scale_num
                scale_num = max(scale_num - 0.1, 0.8)
                if old_scale != scale_num:
                    _clamp_camera_position()
            MOUSE_BUTTON_WHEEL_UP:
                var old_scale = scale_num
                scale_num = min(scale_num + 0.1, 1.6)
                if old_scale != scale_num:
                    _clamp_camera_position()
            MOUSE_BUTTON_LEFT:
                if event.pressed:
                    # 开始拖拽时记录起始位置
                    is_dragging = true
                    drag_start_pos = event.position
                    camera_start_pos = self.position
                else:
                    # 结束拖拽
                    is_dragging = false

    # 处理拖拽移动
    elif event is InputEventMouseMotion and is_dragging:
        var drag_offset = event.position - drag_start_pos
        # 只在水平方向移动，并考虑缩放因素
        var new_x = camera_start_pos.x - drag_offset.x / self.zoom.x

        # 考虑视口大小的边界限制
        var half_view_width = half_viewport_size.x / self.zoom.x
        new_x = clamp(new_x,
            camera_limit_left + half_view_width,
            camera_limit_right - half_view_width)

        # 更新相机位置
        self.position.x = new_x
        self.position.y = camera_start_pos.y

func _process(_delta: float) -> void:
    # 平滑缩放
    var old_zoom = self.zoom
    self.zoom = lerp(self.zoom, Vector2(scale_num, scale_num), 0.1)
    # 如果缩放发生变化，确保位置仍在边界内
    if old_zoom != self.zoom:
        _clamp_camera_position()

# 确保相机位置在有效范围内
func _clamp_camera_position() -> void:
    var half_view_width = half_viewport_size.x / self.zoom.x
    var new_x = clamp(position.x,
        camera_limit_left + half_view_width,
        camera_limit_right - half_view_width)
    self.position.x = new_x

func _on_battle_entered()->void:
    enabled_drag=true
