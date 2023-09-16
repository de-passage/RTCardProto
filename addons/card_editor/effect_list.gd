extends GridContainer

class_name EditorEffectList

const EFFECT_GROUP = ".EFFECT_GROUP"

@onready var _label = $EffectsLabel as Label
@onready var _effect_list = $EffectListButton as OptionButton
@onready var _effect_vbox = $EffectVBox as VBoxContainer


static var _effects: Array[Dictionary]
static var _effect_editor_scene = preload("res://addons/card_editor/effect_editor.tscn")

func _ready():
	if Engine.is_editor_hint():
		_effect_editor_scene = load("res://addons/card_editor/effect_editor.tscn")
	_effect_list.clear()
	_effect_list.add_item("<add effect>")
	_load_effects()
	
	for effect in _effects:
		var name = effect.get("name")
		_effect_list.add_item(name)

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

func set_label(s: String):
	_label.text = s

func get_effect_parameters():
	var result = []
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
		
		var effect_metadata = script.get_metadata()
		effect_metadata["script"] = script
		
		for eff in effect_metadata["parameters"]:
			var name = eff.get("name")
			if name != null and values.has(name): 
				eff.default = values.get(name)

		_add_effect_to_effect_list(effect_metadata)
	
	visible = (array.size() > 0)
	return visible

func _on_draw_option_button_item_selected(index):
	_add_selected_button_item_to_box(index)
	
func _add_selected_button_item_to_box(index: int):
	if index == 0: # Selection cancelled 
		return
	
	var selected_effect = _effects[index-1];
	_add_effect_to_effect_list(selected_effect)
	_effect_list.selected = 0
	
func _add_effect_to_effect_list(selected_effect: Dictionary):
	# Extract name and effect parameters
	var effect_name = selected_effect.get("name", "<Unnamed effect>");
	var expected_parameters: Array = selected_effect.get("parameters", [])
	
	# Create a new effect editor, initialize it and connect its signal
	var effect_value_editor = _effect_editor_scene.instantiate()
	effect_value_editor.add_to_group(EFFECT_GROUP)
	_effect_vbox.add_child(effect_value_editor)
	effect_value_editor.initialize(effect_name, expected_parameters, selected_effect["script"])
	effect_value_editor.deleted.connect(func(): _effect_vbox.remove_child(effect_value_editor))
	_effect_vbox.add_spacer(false)
