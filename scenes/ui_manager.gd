extends CanvasLayer

@onready var main_ui: Control = $MainUI
@onready var level_choose_ui: Control = $LevelChooseUI
@onready var monster_pick_ui: Control = $MonsterPickUI

@onready var login_ui: Node2D = $MainUI/LoginUI
@onready var menu_ui: Node2D = $MainUI/MenuUI
@onready var setting_ui: Node2D = $MainUI/SettingUI

@onready var login_button: Button = $MainUI/LoginUI/LoginBox/LoginButton
@onready var start_battle_button: Button = $MainUI/MenuUI/Panel/StartBattleButton
@onready var upgrade_button: Button = $MainUI/MenuUI/Panel/UpgradeButton
@onready var team_manage_button: Button = $MainUI/MenuUI/Panel/TeamManageButton
@onready var restart_button: Button = $MainUI/SettingUI/RestartButton


signal bettle_entered

func _ready() -> void:
    login_ui.visible=true
    menu_ui.visible=false
    setting_ui.visible=true
    level_choose_ui.visible=false
    monster_pick_ui.visible=false

    login_button.pressed.connect(_on_login_button_pressed)
    start_battle_button.pressed.connect(_on_start_battle_button_pressed)
    restart_button.pressed.connect(_on_restart_button_pressed)


func _on_login_button_pressed() -> void:
    login_ui.visible=false
    menu_ui.visible=true
    level_choose_ui.visible=true


func _on_start_battle_button_pressed() -> void:
    bettle_entered.emit()
    menu_ui.visible=false
    level_choose_ui.visible=false
    monster_pick_ui.visible=true

func _on_restart_button_pressed() -> void:
    get_tree().reload_current_scene()
