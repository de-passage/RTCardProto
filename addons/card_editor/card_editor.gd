@tool
extends ScrollContainer

const EFFECT_GROUP = ".EFFECT_GROUP"
@onready var _name = $VBoxContainer/GridContainer/CardNameEdit as LineEdit
@onready var _cost = $VBoxContainer/GridContainer/CardCostEdit as SpinBox
@onready var _mcost = $VBoxContainer/GridContainer/CardCostEdit2 as SpinBox
@onready var _rarity = $VBoxContainer/GridContainer/CardCostEdit2 as SpinBox
@onready var _errors = $VBoxContainer/Errors as Label
@onready var _effect_list = $VBoxContainer/GridContainer/OptionButton as OptionButton
@onready var _effect_vbox = $VBoxContainer/GridContainer/EffectVBox as VBoxContainer
@onready var _file_explorer = $VBoxContainer/GridContainer/LoadCardButton/FileDialog as FileDialog
@onready var _save_button = $VBoxContainer/SaveButton as Button
@onready var _save_path_edit = $VBoxContainer/GridContainer/SavePath
@onready var _feedback = $VBoxContainer/Feedback

var _effect_editor_scene = preload("res://addons/card_editor/effect_editor.tscn")

var _resources: Array
var _effects: Array[Dictionary]
var _save_path: String: 
	set(value):
		_save_path = value.strip_edges().to_lower()
		_save_path = _file_name_sanitizer.sub(_save_path, "_", true)
		_save_path_edit.text = _save_path
#		if FileAccess.file_exists(_get_file_path(_save_path)): 
#			_overwrite = true
#		else: 
#			_overwrite = false
		
var _overwrite: bool = false:
	set(v):
		_overwrite = v
		$VBoxContainer/SaveButton.text = "Create" if not _overwrite else "Save"
		
var _file_name_regex = RegEx.create_from_string(".*/([^/]+)\\.tres$")
var _file_name_sanitizer =  RegEx.create_from_string("[^a-zA-Z0-9 _-]")

func _get_metadata(e):
	if e is GDScript:
		var x = e.get_metadata()
		if x != null:
			x["script"] = e
			_effects.append(x)
		else: 
			printerr("no metadata in %s" % e.get_class()) 

func _get_file_path(s):
	return "res://Cards/%s.tres" % s

func _load_effects():
	_effects = []
	CGResourceManager.load_resources("res://Scripts/Effects", _get_metadata)

func _ready():
	if Engine.is_editor_hint():
		_effect_editor_scene = load("res://addons/card_editor/effect_editor.tscn")
	_errors.visible = false
	_load_effects()
	_effect_list.clear()
	
	_effect_list.add_item("<add effect>") # This is to enable no selection
	for effect in _effects:
		var name = effect.get("name")
		print("Added effect '%s' " % name)
		_effect_list.add_item(name)

func _on_reset_button_pressed():
	_name.text = ""
	_cost.value = 1
	_mcost.value = 50
	_rarity.value = 0
	_save_path_edit.text = ""
	get_tree().call_group(EFFECT_GROUP, "queue_free")
	_overwrite = false
	
	

func _on_button_pressed():
	var name = _name.text
	var cost = _cost.value
	var mcost = _mcost.value
	var rarity = _rarity.value
	var errors = []
	_errors.visible = false
	
	var resource = CardResource.new() 
	if name.strip_edges() == "":
		errors.append("Name must not be empty") 
	
	resource.cardName = name
	
	if cost < 0: 
		errors.append("Energy cost must not be negative")
	
	resource.cost = cost 
	
	if mcost < 0: 
		errors.append("Money cost must not be negative")
	
	resource.monetaryValue = mcost 
	
	resource.rarity = rarity
	
	resource.cardEffects.clear()

	for child in _effect_vbox.get_children(): 
		if child is EffectEditor: 
			resource.cardEffects.append(child.get_parameters())
	
	var final_save_path = _get_file_path(_save_path_edit.text)
	if not _overwrite and FileAccess.file_exists(final_save_path):
		errors.append("File %s already exist!" % final_save_path)
			
	if errors.size() > 0: 
		_errors.text = "\n".join(errors)
		_errors.visible = true
	else:
		var r = ResourceSaver.save(resource, final_save_path)
		if r == OK: 
			_feedback.text = "'%s' saved successfully!" % name
			var t = Timer.new()
			t.timeout.connect(func(): _feedback.text = "")
			t.one_shot = true
			add_child(t)
			t.start(3)
		else:
			_errors.text = "Save failed!"
	
	

## An item was selected in the effect option box
func _on_option_button_item_selected(index):
	print("Selected item %s" % index)
	if index == 0: # Selection cancelled 
		return
	
	var selected_effect = _effects[index-1];
	_add_effect_to_effect_list(selected_effect)

func _add_effect_to_effect_list(selected_effect: Dictionary):
	var effect_name = selected_effect.get("name", "<Unnamed effect>");
	var expected_parameters: Array = selected_effect.get("parameters", [])
	
	var effect_value_editor = _effect_editor_scene.instantiate()
	effect_value_editor.add_to_group(EFFECT_GROUP)
	
	_effect_vbox.add_child(effect_value_editor)
	effect_value_editor.initialize(effect_name, expected_parameters, selected_effect["script"])
	effect_value_editor.deleted.connect(func(): _effect_vbox.remove_child(effect_value_editor))
	_effect_vbox.add_spacer(false)


func _on_file_dialog_file_selected(path: String):
	var card_resource = load(path)
	if card_resource is CardResource:
		_errors.visible = false
		
		var reg_res = _file_name_regex.search(path)
		
		if reg_res:
			_overwrite = true
			_save_path = reg_res.get_string(1)
		else:
			_overwrite = false
			_save_path = path
		
		_name.text = card_resource.cardName
		_cost.value = card_resource.cost
		_mcost.value = card_resource.monetaryValue
		_rarity.value = card_resource.rarity
		
		get_tree().call_group(EFFECT_GROUP, "queue_free")
		
		for effect in card_resource.cardEffects: 
			var script = effect.effectScript
			var values = effect.effectValues
			
			var effect_metadata = script.get_metadata()
			effect_metadata["script"] = script
			
			for eff in effect_metadata["parameters"]:
				var name = eff.get("name")
				if name != null and values.has(name): 
					eff.default = values.get(name)
				

			_add_effect_to_effect_list(effect_metadata)


func _on_card_name_edit_text_submitted(new_text):
	_save_path = new_text

func _on_load_card_button_pressed():
	_file_explorer.popup_centered_ratio()
