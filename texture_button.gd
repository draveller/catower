extends TextureButton

@export var level_number: int = 1
@export var radius: float = 200.0  # 按钮到中心的距离
@export var angle: float = 0.0     # 按钮的角度

func _ready() -> void:
    # 设置按钮位置
    position = Vector2(
        radius * cos(angle),
        radius * sin(angle)
    )
