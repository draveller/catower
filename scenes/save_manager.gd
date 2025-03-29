extends Node


var save_path = "user://catower_save.json"

var file_pass = "%VY1^Cky+WqK.~]]>3y6"

# 游戏初始存档
const initial_data: Dictionary = {
    "commander_level": 1,
    "energy": 100,
    "cat_coin": 500
}

# 游戏实时存档
var current_data: Dictionary = {}


func _ready() -> void:
    if not FileAccess.file_exists(save_path):
        init_data()

    load_data()

func init_data() -> void:
    current_data = initial_data
    save_data()

func save_data() -> void:
    var file = FileAccess.open_encrypted_with_pass(save_path, FileAccess.WRITE, file_pass)
    file.store_var(current_data.duplicate())
    file.close()


func load_data() -> void:
    var file = FileAccess.open_encrypted_with_pass(save_path, FileAccess.READ, file_pass)
    var data = file.get_var()
    file.close()
    current_data = data.duplicate()
