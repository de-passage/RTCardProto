@tool
extends VBoxContainer

class_name SimplifiedCardEditor

signal deleted

@onready var _name_edit = $Attr/NameEdit as LineEdit
@onready var _cost_edit = $Attr/CostEdit as SpinBox
@onready var _effect_list = $Attr/EffectEdit as OptionButton
@onready var _effect_vbox = $Attr/EffectVBox as VBoxContainer

## The resource that this object was instantiated with
var _card_resource : CardResource


var _effects : Array = []
static var _effect_editor_scene = preload("res://addons/card_editor/effect_editor.tscn")
const EFFECT_GROUP = ".EFFECT_GROUP"

# true if the card resource must be saved directly inside a monster (incomplete card)
var anonymous: bool:
	set(value):
		anonymous = value
		_name_edit.visible = !anonymous
		_cost_edit.editable = anonymous
		_effect_list.disabled = !anonymous
	get:
		return anonymous

var cost: int:
	set(value):
		_card_resource.cost = value
	get:
		return _card_resource.cost

func _ready():
	_load_effects()
	_effect_list.clear()
	
	_effect_list.add_item("<add effect>") # This is to enable no selection
	for effect in _effects:
		var name = effect.get("name")
		_effect_list.add_item(name)

func initialize_from_card(card: CardResource):
	anonymous = false
	_initialize(card)

func _initialize(card: CardResource):
	_name_edit.text = card.cardName
	_cost_edit.value = card.cost
	_card_resource = card
	for effect in card.cardEffects:
		var script = effect.effectScript
		var values = effect.effectValues
		
		if script == null: continue
		var effect_metadata = script.get_metadata()
		effect_metadata["script"] = script
		
		for eff in effect_metadata["parameters"]:
			var name = eff.get("name")
			if name != null and values.has(name): 
				eff.default = values.get(name)

		_add_effect_to_effect_list(effect_metadata)

func initialize_anonymous(card: CardResource): 
	anonymous = true
	card.resource_path = ""
	_initialize(card)
	
func _get_metadata(e):
	if e is GDScript:
		var x = e.get_metadata()
		if x != null:
			x["script"] = e
			_effects.append(x)

		else: 
			printerr("no metadata in %s" % e.get_class()) 

func _load_effects():
	_effects = []
	CGResourceManager.load_resources("res://Scripts/Effects", _get_metadata)

func _add_effect_to_effect_list(selected_effect: Dictionary):
	var effect_name = selected_effect.get("name", "<Unnamed effect>");
	var expected_parameters: Array = selected_effect.get("parameters", [])
	
	var effect_value_editor = _effect_editor_scene.instantiate()
	
	_effect_vbox.add_child(effect_value_editor)
	effect_value_editor.initialize(effect_name, expected_parameters, selected_effect["script"])
	effect_value_editor.deleted.connect(func(): _effect_vbox.remove_child(effect_value_editor))
	_effect_vbox.add_spacer(false)


func _on_effect_edit_item_selected(index):
	if index > 0:
		_add_effect_to_effect_list(_effects[index - 1])
	_effect_list.select(0)

func get_card_resource() -> CardResource:
	_card_resource.cardEffects = []
	for ef in _effect_vbox.get_children():
		if ef is EffectEditor:
			_card_resource.cardEffects.append(ef.get_parameters())
	return _card_resource


func _on_delete_button_pressed():
	queue_free()
	deleted.emit()
