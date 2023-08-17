@tool
extends Control

@onready var _name_edit = $GridContainer/NameEdit as LineEdit
@onready var _health_edit = $GridContainer/HealthEdit as SpinBox
@onready var _coin_edit = $GridContainer/CoinEdit as SpinBox
@onready var _attack_frequency_edit = $GridContainer/AttackFrequencyEdit as SpinBox
@onready var _card_reward_edit = $GridContainer/CardRewardEdit as CheckBox
@onready var _type_edit = $GridContainer/TypeEdit as OptionButton
@onready var _level_edit = $GridContainer/LevelEdit as OptionButton
@onready var _card_list_edit = $GridContainer/CardListEdit as ItemList
@onready var _file_dialog = $GridContainer/LoadButton/FileDialog as FileDialog

var _displayed_cards = []

const MONSTER_PATH = CGResourceManager.ENEMIES_PATH

func _ready():
	_load_available_cards()
	
func _load_available_cards():
	_card_list_edit.clear()
	for card in CGResourceManager.load_cards():
		var name = card.cardName
		_card_list_edit.add_item(name)

func _load_monster(path): 
	var monster = load(path) as EnemyResource
	_name_edit.text = monster.name
	_health_edit.value = monster.health
	_coin_edit.value = monster.coin_value
	_attack_frequency_edit.value = monster.attack_frequency
	_type_edit.selected = monster.type
	_level_edit.selected = monster.level
	


func _on_load_button_pressed():
	_file_dialog.popup_centered_ratio()


func _on_file_dialog_file_selected(path):
	_load_monster(path)
