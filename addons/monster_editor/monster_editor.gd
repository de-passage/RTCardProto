@tool
extends Control

@onready var _name_edit = $GridContainer/Attr/NameEdit as LineEdit
@onready var _health_edit = $GridContainer/Attr/HealthEdit as SpinBox
@onready var _coin_edit = $GridContainer/Attr/CoinEdit as SpinBox
@onready var _attack_frequency_edit = $GridContainer/Attr/AttackFrequencyEdit as SpinBox
@onready var _card_reward_edit = $GridContainer/Attr/CardRewardEdit as CheckBox
@onready var _type_edit = $GridContainer/Attr/TypeEdit as OptionButton
@onready var _level_edit = $GridContainer/Attr/LevelEdit as OptionButton
@onready var _card_list_edit = $GridContainer/Attr/CardListEdit as ItemList
@onready var _file_dialog = $GridContainer/Attr/LoadButton/FileDialog as FileDialog
@onready var _card_box = $Attr/GridContainer/CardVBox as HBoxContainer

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
