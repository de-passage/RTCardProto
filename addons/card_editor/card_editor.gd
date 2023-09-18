@tool
extends ScrollContainer

@onready var _name = $EditorPanel/VBoxContainer/GridContainer/CardNameEdit as LineEdit
@onready var _cost = $EditorPanel/VBoxContainer/GridContainer/CardCostEdit as SpinBox
@onready var _mana_cost_edit = $EditorPanel/VBoxContainer/GridContainer/CardManaCostEdit as SpinBox
@onready var _mcost = $EditorPanel/VBoxContainer/GridContainer/CardCostEdit2 as SpinBox
@onready var _rarity = $EditorPanel/VBoxContainer/GridContainer/CardRarityEdit as SpinBox
@onready var _errors = $EditorPanel/VBoxContainer/Errors as Label
@onready var _feedback = $EditorPanel/VBoxContainer/Feedback
@onready var _playable_checkbox = $EditorPanel/VBoxContainer/GridContainer/EffectsBoxList/PlayableCheckbox as CheckBox

# Tags
@onready var _tag_edit = $EditorPanel/VBoxContainer/TagsGrid/TagAddContainer/TagEdit
@onready var _tag_list = $EditorPanel/VBoxContainer/TagsGrid/TagList as HBoxContainer

# Pools
@onready var _pool_edit = $EditorPanel/VBoxContainer/TagsGrid/PoolsAddContainer/PoolEdit
@onready var _pool_list = $EditorPanel/VBoxContainer/TagsGrid/PoolList as HBoxContainer

@onready var _draw_effects = %DrawEffectList as EditorEffectList
@onready var _discard_effects = %DiscardEffectList as EditorEffectList
@onready var _play_effects = %PlayEffectList as EditorEffectList
@onready var _on_play_checkbox = %OnPlayCheckBox as CheckBox
@onready var _on_draw_checkbox = %OnDrawCheckBox as CheckBox
@onready var _on_discard_checkbox = %OnDiscardCheckBox as CheckBox

@onready var _editor_panel = $EditorPanel as EditorControlPanel

const BUTTONS_GROUP = ".CardEditorButton"
const USER_CARD_PATH = "user://Cards"

var _resources: Array
var _save_path: String: 
	set(value):
		_save_path = value.strip_edges().to_lower()
		_save_path = _file_name_sanitizer.sub(_save_path, "_", true)
		
var _overwrite: bool = false
		
var _file_name_regex = RegEx.create_from_string("res://Cards/(.*)\\.tres$")
var _file_name_sanitizer =  RegEx.create_from_string("[^a-zA-Z0-9_/-]")

func _get_file_path(s):
	return "res://Cards/%s.tres" % s


func _ready():
	_errors.visible = false
	_play_effects.set_label("On play")
	_discard_effects.set_label("On discard")
	_draw_effects.set_label("On draw")
	if not Engine.is_editor_hint():
		if not DirAccess.dir_exists_absolute(USER_CARD_PATH):
			DirAccess.make_dir_absolute(USER_CARD_PATH)
		var editor = $EditorPanel as EditorControlPanel
		editor.access = FileDialog.Access
		editor.root_subfolder = "user://Cards"
		

func _on_reset_button_pressed():
	_name.text = ""
	_cost.value = 1
	_mcost.value = 50
	_rarity.value = 0
	get_tree().call_group(EditorEffectList.EFFECT_GROUP, "queue_free")
	_overwrite = false
	_discard_effects.visible = false
	_draw_effects.visible = false
	_play_effects.visible = true

func attach_to_editor(editor: EditorInterface):
	_editor_panel.attach_to_editor(editor)
	
	
##################################
#   SAVE LOGIC 
##################################
func _on_editor_panel_save_required(path):
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
	
	resource.on_draw_card_effects = _draw_effects.get_effect_parameters()
	resource.on_play_card_effects = _play_effects.get_effect_parameters()
	resource.on_discard_card_effects = _discard_effects.get_effect_parameters()
				
	for tag in _tag_list.get_children():
		if tag is Button:
			resource.tags.append(tag.text)
	for pool in _pool_list.get_children():
		if pool is Button:
			resource.pools.append(pool.text)
			
	if errors.size() > 0: 
		_errors.text = "\n".join(errors)
		_errors.visible = true
	else:
		var r = ResourceSaver.save(resource, path)
		if r == OK: 
			_feedback.text = "'%s' saved successfully!" % name
			var t = Timer.new()
			t.timeout.connect(func(): _feedback.text = "")
			t.one_shot = true
			add_child(t)
			t.start(3)
		else:
			_errors.text = "Save failed!"


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
		
		get_tree().call_group(EditorEffectList.EFFECT_GROUP, "queue_free")

		_on_play_checkbox.button_pressed = \
			_play_effects.build_effect_editor_from_resources(card_resource.on_play_card_effects)
		_on_discard_checkbox.button_pressed = \
			_discard_effects.build_effect_editor_from_resources(card_resource.on_discard_card_effects)
		_on_draw_checkbox.button_pressed = \
			_draw_effects.build_effect_editor_from_resources(card_resource.on_draw_card_effects)
		
		for tag in card_resource.tags:
			_add_tag_delete_button(tag)
		for pool in card_resource.pools: 
			_add_pool_delete_button(pool)
	

func _add_tag_delete_button(value: StringName):
	_add_button_to_list(value, _tag_list)
	_tag_edit.text = ''
	
func _add_button_to_list(value: StringName, list: BoxContainer):
	var button = Button.new()
	list.add_child(button)
	button.pressed.connect(func(): button.queue_free())
	button.text = value
	button.add_to_group(BUTTONS_GROUP)

func _add_pool_delete_button(value: StringName):
	_add_button_to_list(value, _pool_list)
	_pool_edit.text = ''

# #################################
# SIGNALS
###################################

func _on_card_name_edit_text_submitted(new_text):
	_save_path = new_text


func _on_add_tag_button_pressed():
	var value = _tag_edit.text
	_add_tag_delete_button(value)


func _on_tag_edit_text_submitted(new_text):
	_add_tag_delete_button(new_text)


func _on_on_play_check_box_toggled(button_pressed):
	_play_effects.visible = button_pressed


func _on_on_draw_check_box_toggled(button_pressed):
	_draw_effects.visible = button_pressed


func _on_on_discard_check_box_toggled(button_pressed):
	_discard_effects.visible = button_pressed

	

func _on_add_pool_button_pressed():
	var value = _pool_edit.text
	_add_pool_delete_button(value)


func _on_pool_edit_text_submitted(new_text):
	_add_pool_delete_button(new_text)

