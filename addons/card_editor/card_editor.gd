@tool
extends ScrollContainer

const EFFECT_GROUP = ".EFFECT_GROUP"
@onready var _name = $VBoxContainer/GridContainer/CardNameEdit as LineEdit
@onready var _cost = $VBoxContainer/GridContainer/CardCostEdit as SpinBox
@onready var _mana_cost_edit = $VBoxContainer/GridContainer/CardManaCostEdit as SpinBox
@onready var _mcost = $VBoxContainer/GridContainer/CardCostEdit2 as SpinBox
@onready var _rarity = $VBoxContainer/GridContainer/CardRarityEdit as SpinBox
@onready var _errors = $VBoxContainer/Errors as Label
@onready var _file_explorer = $VBoxContainer/GridContainer/LoadCardButton/FileDialog as FileDialog
@onready var _save_button = $VBoxContainer/SaveButton as Button
@onready var _save_path_edit = $VBoxContainer/GridContainer/SavePath
@onready var _feedback = $VBoxContainer/Feedback
@onready var _playable_checkbox = $VBoxContainer/GridContainer/EffectsBoxList/PlayableCheckbox as CheckBox

# Tags
@onready var _tag_edit = $VBoxContainer/GridContainer/TagAddContainer/TagEdit
@onready var _tag_list = $VBoxContainer/GridContainer/TagList as HBoxContainer

# Pools
@onready var _pool_edit = $VBoxContainer/GridContainer/PoolsAddContainer/PoolEdit
@onready var _pool_list = $VBoxContainer/GridContainer/PoolList as HBoxContainer


# On play effects 
@onready var _play_effect_list = $VBoxContainer/GridContainer/PlayOptionButton as OptionButton
@onready var _play_effect_vbox = $VBoxContainer/GridContainer/PlayEffectVBox as VBoxContainer
@onready var _play_checkbox = $VBoxContainer/GridContainer/EffectsBoxList/OnPlayCheckBox as CheckBox

# On draw effects
@onready var _draw_effect_list = $VBoxContainer/GridContainer/DrawOptionButton as OptionButton
@onready var _draw_effect_vbox = $VBoxContainer/GridContainer/DrawEffectVBox as VBoxContainer
@onready var _draw_checkbox = $VBoxContainer/GridContainer/EffectsBoxList/OnDrawCheckBox as CheckBox

# On discard effects
@onready var _discard_effect_list = $VBoxContainer/GridContainer/DiscardOptionButton as OptionButton
@onready var _discard_effect_vbox = $VBoxContainer/GridContainer/DiscardEffectVBox as VBoxContainer
@onready var _discard_checkbox = $VBoxContainer/GridContainer/EffectsBoxList/OnDiscardCheckBox as CheckBox

static var _effect_editor_scene = preload("res://addons/card_editor/effect_editor.tscn")

var _resources: Array
static var _effects: Array[Dictionary]
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
		
var _file_name_regex = RegEx.create_from_string("res://Cards/(.*)\\.tres$")
var _file_name_sanitizer =  RegEx.create_from_string("[^a-zA-Z0-9_/-]")

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
	_play_effect_list.clear()
	_draw_effect_list.clear()
	_discard_effect_list.clear()
	
	_play_effect_list.add_item("<add effect>") # This is to enable no selection
	_draw_effect_list.add_item("<add effect>")
	_discard_effect_list.add_item("<add effect>")
	for effect in _effects:
		var name = effect.get("name")
		_play_effect_list.add_item(name)
		_draw_effect_list.add_item(name)
		_discard_effect_list.add_item(name)

func _on_reset_button_pressed():
	_name.text = ""
	_cost.value = 1
	_mcost.value = 50
	_rarity.value = 0
	_save_path_edit.text = ""
	get_tree().call_group(EFFECT_GROUP, "queue_free")
	_overwrite = false
	get_tree().call_group("on_play", "set_visible", true)
	get_tree().call_group("on_draw", "set_visible", false)
	get_tree().call_group("on_discard", "set_visible", false)
	
##################################
#   SAVE LOGIC 
##################################
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
	
	resource.card_name = name
	
	if cost < 0: 
		errors.append("Energy cost must not be negative")
	
	resource.cost = cost
	resource.mana_cost = _mana_cost_edit.value 
	
	if mcost < 0: 
		errors.append("Money cost must not be negative")
	
	resource.monetary_value = mcost 
	
	resource.rarity = rarity
	
	resource.on_play_card_effects.clear()
	resource.playable = _playable_checkbox.button_pressed
	
	if _play_checkbox.button_pressed: 
		for child in _play_effect_vbox.get_children(): 
			if child is EffectEditor: 
				resource.on_play_card_effects.append(child.get_parameters())
	
	if _discard_checkbox.button_pressed:
		for child in _discard_effect_vbox.get_children(): 
			if child is EffectEditor: 
				resource.on_discard_card_effects.append(child.get_parameters())
	
	if _draw_checkbox.button_pressed:
		for child in _draw_effect_vbox.get_children(): 
			if child is EffectEditor: 
				resource.on_draw_card_effects.append(child.get_parameters())
				
	for tag in _tag_list.get_children():
		if tag is Button:
			resource.tags.append(tag.text)
	for pool in _pool_list.get_children():
		if pool is Button:
			resource.pools.append(pool.text)
	
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
	
	

static func _add_effect_to_effect_list(selected_effect: Dictionary, effect_box: VBoxContainer):
	# Extract name and effect parameters
	var effect_name = selected_effect.get("name", "<Unnamed effect>");
	var expected_parameters: Array = selected_effect.get("parameters", [])
	
	# Create a new effect editor, initialize it and connect its signal
	var effect_value_editor = _effect_editor_scene.instantiate()
	effect_value_editor.add_to_group(EFFECT_GROUP)
	effect_box.add_child(effect_value_editor)
	effect_value_editor.initialize(effect_name, expected_parameters, selected_effect["script"])
	effect_value_editor.deleted.connect(func(): effect_box.remove_child(effect_value_editor))
	effect_box.add_spacer(false)


####################
# LOAD LOGIC 
####################
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
		
		_name.text = card_resource.card_name
		_cost.value = card_resource.cost
		_mcost.value = card_resource.monetary_value
		_rarity.value = card_resource.rarity
		_playable_checkbox.button_pressed = card_resource.playable
		_mana_cost_edit.value = card_resource.mana_cost
		
		get_tree().call_group(EFFECT_GROUP, "queue_free")

		_build_effect_editor_from_resources(card_resource.on_play_card_effects, _play_effect_vbox, _play_checkbox, "on_play")
		_build_effect_editor_from_resources(card_resource.on_draw_card_effects, _draw_effect_vbox, _draw_checkbox, "on_draw")
		_build_effect_editor_from_resources(card_resource.on_discard_card_effects, _discard_effect_vbox, _discard_checkbox, "on_discard")
		
		for tag in card_resource.tags:
			_add_tag_delete_button(tag)
		for pool in card_resource.pools: 
			_add_pool_delete_button(pool)

func _build_effect_editor_from_resources(array: Array[EffectResource], box: VBoxContainer, checkbox: CheckBox, group: StringName):		
	if array == null: 
		return 
	
	var visible = (array.size() > 0)
	get_tree().call_group(group, "set_visible", visible)
	checkbox.button_pressed = visible
	
	for effect in array: 
		var script = effect.effectScript
		var values = effect.effectValues
		
		var effect_metadata = script.get_metadata()
		effect_metadata["script"] = script
		
		for eff in effect_metadata["parameters"]:
			var name = eff.get("name")
			if name != null and values.has(name): 
				eff.default = values.get(name)

		_add_effect_to_effect_list(effect_metadata, box)
	

func _add_tag_delete_button(value: StringName):
	_add_button_to_list(value, _tag_list)
	_tag_edit.text = ''
	
func _add_button_to_list(value: StringName, list: BoxContainer):
	var button = Button.new()
	list.add_child(button)
	button.pressed.connect(func(): button.queue_free())
	button.text = value
	button.add_to_group(EFFECT_GROUP)

func _add_pool_delete_button(value: StringName):
	_add_button_to_list(value, _pool_list)
	_pool_edit.text = ''

# #################################
# SIGNALS
###################################

func _on_card_name_edit_text_submitted(new_text):
	_save_path = new_text

func _on_load_card_button_pressed():
	_file_explorer.popup_centered_ratio()


func _on_add_tag_button_pressed():
	var value = _tag_edit.text
	_add_tag_delete_button(value)


func _on_tag_edit_text_submitted(new_text):
	_add_tag_delete_button(new_text)


func _on_on_play_check_box_toggled(button_pressed):
	get_tree().call_group("on_play", "set_visible", button_pressed)


func _on_on_draw_check_box_toggled(button_pressed):
	get_tree().call_group("on_draw", "set_visible", button_pressed)


func _on_on_discard_check_box_toggled(button_pressed):
	get_tree().call_group("on_discard", "set_visible", button_pressed)

## An item was selected in the effect option box
func _on_option_button_item_selected(index):
	_add_selected_button_item_to_box(index, _play_effect_list, _play_effect_vbox)

func _on_draw_option_button_item_selected(index):
	_add_selected_button_item_to_box(index, _draw_effect_list, _draw_effect_vbox)

func _on_discard_option_button_item_selected(index):
	_add_selected_button_item_to_box(index, _discard_effect_list, _discard_effect_vbox)

static func _add_selected_button_item_to_box(index: int, list: OptionButton, box: VBoxContainer):
	if index == 0: # Selection cancelled 
		return
	
	var selected_effect = _effects[index-1];
	_add_effect_to_effect_list(selected_effect, box)
	list.selected = 0
	

func _on_add_pool_button_pressed():
	var value = _pool_edit.text
	_add_pool_delete_button(value)


func _on_pool_edit_text_submitted(new_text):
	_add_pool_delete_button(new_text)
