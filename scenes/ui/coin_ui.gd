extends HBoxContainer

var energy: int
var cat_coin: int

@onready var energy_label: RichTextLabel = $EnergyLabel
@onready var cat_coin_label: RichTextLabel = $CatCoinLabel


func _ready() -> void:
    load_from_save()


func load_from_save() -> void:
    energy = SaveManager.current_data.energy
    cat_coin = SaveManager.current_data.cat_coin
    energy_label.text = str(energy)
    cat_coin_label.text = str(cat_coin)
