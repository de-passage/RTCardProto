@tool
extends GridContainer

class_name EditorEffectList

const EFFECT_GROUP = ".EFFECT_GROUP"

@onready var _label = $EffectsLabel as Label
@onready var _effect_list = $EffectListButton as OptionButton
@onready var _effect_vbox = $EffectVBox as VBoxContainer

var min_size: int = 200:
	set(value):
		min_size = value
		if _label != null:
			_label.custom_minimum_size = Vector2(value, 0)

var _label_text

class EffectDescription:
	var name: String
	var parameters: Dictionary
	var effect_script: GDScript
	
	func _init(n: String, script: GDScript, params = {}):
		name = n
		effect_script = script
		parameters = params

static var _effects: Array[EffectDescription]
static var _effect_editor_scene = preload("res://addons/card_editor/effect_editor.tscn")

func _ready():
	if Engine.is_editor_hint() and _effect_editor_scene == null:
		_effect_editor_scene = load("res://addons/card_editor/effect_editor.tscn")
	_effect_list.clear()
	_effect_list.add_item("<add effect>")
	var known_effects = CGResourceManager.effects
	
	for effect in known_effects:
		var name = effect.editor_name()
		if name == null:
			printerr("editor_name() is undefined for " % effect.resource_path)
		_effect_list.add_item(name)
		_effects.append(EffectDescription.new(name, effect))
	
	if _label_text != null:
		_label.text = _label_text
	
	_label.custom_minimum_size = Vector2(min_size, 0)

func set_label(s: String):
	_label_text = s
	if _label != null:
		_label.text = _label_text

func get_effect_parameters() -> Array[EffectResource]:
	var result: Array[EffectResource] = []
	for child in _effect_vbox.get_children(): 
		if child is EffectEditor: 
			result.append(child.get_parameters())
	return result

func build_effect_editor_from_resources(array: Array[EffectResource]) -> bool:
	if array == null: 
		return false
	
	for effect in array: 
		var script = effect.effectScript
		var values = effect.effectValues
		
		var name = script.editor_name()
		if name == null: 
			printerr("editor_name() is undefined for %s" % script.resource_path)
			continue

		_add_effect_to_effect_list(EffectDescription.new(name, script, values))
	return array.size() > 0

func _on_draw_option_button_item_selected(index):
	_add_selected_button_item_to_box(index)
	
func _add_selected_button_item_to_box(index: int):
	if index == 0: # Selection cancelled 
		return
	
	var selected_effect = _effects[index-1];
	_add_effect_to_effect_list(selected_effect)
	_effect_list.selected = 0
	
func _add_effect_to_effect_list(selected_effect: EffectDescription):
	
	# Create a new effect editor, initialize it and connect its signal
	var effect_value_editor = _effect_editor_scene.instantiate() as EffectEditor
	effect_value_editor.add_to_group(EFFECT_GROUP)
	_effect_vbox.add_child(effect_value_editor)
	effect_value_editor.initialize(
		selected_effect.name,
		selected_effect.parameters,
		selected_effect.effect_script)
	effect_value_editor.deleted.connect(func(): _effect_vbox.remove_child(effect_value_editor))
	_effect_vbox.add_spacer(false)
