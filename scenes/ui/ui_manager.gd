extends CanvasLayer


@onready var login_ui: Control = $LoginUI
@onready var menu_ui: Control = $MenuUI
@onready var setting_ui: Control = $SettingUI
@onready var level_choose_ui: Control = $LevelChooseUI
@onready var monster_pick_ui: Control = $MonsterPickUI


@onready var login_button: Button = $LoginUI/LoginBox/LoginButton
@onready var start_battle_button: Button = $MenuUI/StartBattleButton
@onready var restart_button: Button = $SettingUI/RestartButton
@onready var monster_manage_button: Button = $MenuUI/MonsterManageButton
@onready var collection_button: Button = $MenuUI/CollectionButton


func _ready() -> void:
    login_button.pressed.connect(_on_menu_scene_entered)
    start_battle_button.pressed.connect(_on_battle_scene_entered)
    restart_button.pressed.connect(_on_login_scene_entered)
    _on_login_scene_entered()

# 进入登录场景
func _on_login_scene_entered() -> void:
    login_ui.visible = true
    menu_ui.visible = false
    setting_ui.visible = true
    level_choose_ui.visible = false
    monster_pick_ui.visible = false

# 进入主菜单场景
func _on_menu_scene_entered() -> void:
    login_ui.visible = false
    menu_ui.visible = true
    setting_ui.visible = true
    level_choose_ui.visible = true
    monster_pick_ui.visible = false

# 进入战斗场景
func _on_battle_scene_entered() -> void:
    login_ui.visible = false
    menu_ui.visible = false
    setting_ui.visible = true
    level_choose_ui.visible = false
    monster_pick_ui.visible = true
    SignalBus.emit_signal("battle_entered")
