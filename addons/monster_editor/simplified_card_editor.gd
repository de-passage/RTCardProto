@tool
extends VBoxContainer

class_name SimplifiedCardEditor

signal deleted

@onready var _name_edit = $Attr/NameEdit as LineEdit
@onready var _cost_edit = $Attr/CostEdit as SpinBox
@onready var _effects = $Attr/EffectList as EditorEffectList

## The resource that this object was instantiated with
var _card_resource : CardResource

static var _effect_editor_scene = preload("res://addons/card_editor/effect_editor.tscn")
const EFFECT_GROUP = ".EFFECT_GROUP"

# true if the card resource must be saved directly inside a monster (incomplete card)
var anonymous: bool:
	set(value):
		anonymous = value
		_name_edit.visible = !anonymous
		_cost_edit.editable = anonymous
	get:
		return anonymous

var cost: int:
	set(value):
		_card_resource.cost = value
	get:
		return _card_resource.cost


func initialize_from_card(card: CardResource):
	anonymous = false
	_initialize(card)

func _initialize(card: CardResource):
	_name_edit.text = card.card_name
	_cost_edit.value = card.cost
	_card_resource = card
	
	_effects.build_effect_editor_from_resources(_card_resource.on_play_card_effects)

func initialize_anonymous(card: CardResource): 
	anonymous = true
	card.resource_path = ""
	_initialize(card)


func get_card_resource() -> CardResource:
	_card_resource.on_play_card_effects = _effects.get_effect_parameters()
	return _card_resource


func _on_delete_button_pressed():
	queue_free()
	deleted.emit()
