extends TextureButton


func _ready() -> void:
    size = Vector2(240, 120)


func _on_pressed() -> void:
    var crabby = load("res://scenes/character/super_crabby.tscn").instantiate()
    var pinky = load("res://scenes/character/pinky.tscn").instantiate()
    # 获取当前场景根节点
    var root = get_tree().root

    # 设置生成区域的范围
    var spawn_area_left := -1200
    var spawn_area_right := -1200
    var spawn_area_top := -200
    var spawn_area_bottom := -100

    # 在指定区域内随机生成位置
    var random_x := randf_range(spawn_area_left, spawn_area_right)
    var random_y := randf_range(spawn_area_top, spawn_area_bottom)
    crabby.position = Vector2(random_x, random_y)
    pinky.position = Vector2(random_x+500, random_y)

    # 将螃蟹怪添加到场景中
    root.add_child(crabby)
    root.add_child(pinky)
