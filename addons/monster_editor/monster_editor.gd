@tool
extends Control

@onready var _name_edit = $Attr/GridContainer/NameEdit as LineEdit
@onready var _health_edit = $Attr/GridContainer/HealthEdit as SpinBox
@onready var _coin_edit = $Attr/GridContainer/CoinEdit as SpinBox
@onready var _attack_frequency_edit = $Attr/GridContainer/AttackFrequencyEdit as SpinBox
@onready var _card_reward_edit = $Attr/GridContainer/CardRewardEdit as CheckBox
@onready var _type_edit = $Attr/GridContainer/TypeEdit as OptionButton
@onready var _level_edit = $Attr/GridContainer/LevelEdit as OptionButton
@onready var _card_list_edit = $Attr/GridContainer/CardListEdit as OptionButton
@onready var _file_dialog = $Attr/GridContainer/LoadButton/LoadFileDialog as FileDialog
@onready var _save_file_dialog = $Attr/GridContainer/ControlBox/Save/SaveFileDialog as FileDialog
@onready var _card_box = $Attr/GridContainer/CardVBox as VBoxContainer

var _displayed_cards = []
var _available_cards: Array[CardResource] = []
static var _simplified_card_editor_scene = preload("res://addons/monster_editor/simplified_card_editor.tscn")
var _current_enemy_resource: EnemyResource

const MONSTER_PATH = CGResourceManager.ENEMIES_PATH
const CARD_GROUP = ".CARD_GROUP"

func _ready():
	_load_available_cards()

func _load_available_cards():
	_available_cards.clear()
	_card_list_edit.clear()
	_card_list_edit.add_item("<Add card>");
	_card_list_edit.add_item("[New anonymous card]");
	for card in CGResourceManager.load_cards():
		var name = card.card_name
		_card_list_edit.add_item(name)
		_available_cards.append(card)

func _load_monster(path):
	var monster = load(path) as EnemyResource
	_update_ui_with_resource(monster)

func _update_ui_with_resource(monster: EnemyResource):
	_current_enemy_resource = monster
	_name_edit.text = monster.name
	_health_edit.value = monster.health
	_coin_edit.value = monster.coin_value
	_attack_frequency_edit.value = monster.attack_frequency
	_type_edit.selected = monster.type
	_level_edit.selected = monster.level
	_displayed_cards = monster.effects
	
	get_tree().call_group(CARD_GROUP, "queue_free")
	for card in _displayed_cards:
		# TODO: improve null resource handling
		if card == null or not card is CardResource:
			return
		var editor = _simplified_card_editor_scene.instantiate()
		editor.add_to_group(CARD_GROUP)
		_card_box.add_child(editor)
		if card.resource_path != "":
			editor.initialize_anonymous(card)
		else:
			# editor.initialize_from_card(card)
			editor.initialize_anonymous(card.duplicate())

func _on_load_button_pressed():
	_file_dialog.popup_centered_ratio()


func _on_file_dialog_file_selected(path):
	_load_monster(path)


func _on_button_pressed():
	_load_available_cards()


func _on_card_list_edit_item_selected(index):
	if index == 0:
		return 
		
	var card_editor: SimplifiedCardEditor = _simplified_card_editor_scene.instantiate()
	_card_box.add_child(card_editor)
	var card: CardResource
	if index == 1:
		card = CardResource.new()
		card_editor.initialize_anonymous(card)
	else:
		card = _available_cards[index - 2]
		card_editor.initialize_anonymous(card.duplicate())
	
	_displayed_cards.append(card)
	_card_list_edit.select(0)

func _on_save_pressed():
	_save_file_dialog.popup_centered_ratio()


func _on_save_file_dialog_file_selected(path):
	_current_enemy_resource.resource_path = path
	_current_enemy_resource.attack_frequency = _attack_frequency_edit.value
	_current_enemy_resource.name = _name_edit.text
	_current_enemy_resource.health = _health_edit.value
	_current_enemy_resource.coin_value = _coin_edit.value
	_current_enemy_resource.card_reward = _card_reward_edit.button_pressed
	
	_current_enemy_resource.effects.clear()
	for item in _card_box.get_children():
		if item is SimplifiedCardEditor:
			var card: CardResource = item.get_card_resource()
			_current_enemy_resource.effects.append(card)
	
	var r = ResourceSaver.save(_current_enemy_resource, path)
	if r == OK:
		print("Save succeeded")
	else:
		printerr("Save failed")

func _on_name_edit_text_submitted(new_text):
	_save_file_dialog.get_line_edit().text = "%s.tres" % new_text


func _on_reset_button_pressed():
	var monster = EnemyResource.new()
	_update_ui_with_resource(monster)
	_current_enemy_resource.resource_path = ""
