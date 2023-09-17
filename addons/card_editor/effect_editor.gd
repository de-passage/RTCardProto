@tool
extends GridContainer
class_name EffectEditor

signal deleted

@onready var _effect_name = $BoxContainer/Margin/Control/EffectName
@onready var _delete_button = $BoxContainer/Margin/Control/DeleteButton
@onready var _grid = $GridContainer as GridContainer

class Proxy:
	var name: String
	var parameter_inputs: Dictionary
	var parameter_values: Dictionary
	
	func _init(name: String):
		self.name = name
	
	func add_int_input(name: String, value: int) -> SpinBox:
		var value_input = SpinBox.new()
		var setter = add_control(name, value_input)
		value_input.value = value
		value_input.value_changed.connect(setter)
		return value_input
	
	func add_card_input(name: String, value: String) -> OptionButton:
		var value_input = OptionButton.new()
		var current = 0
		for card in CGResourceManager.cards:
			value_input.add_item(card.card_name)
			if value != null and value == card.resource_path:
				value_input.select(current)
			current += 1
		var setter = add_control(name, value_input)
		value_input.item_selected\
			.connect(func(idx): 
				setter.call(CGResourceManager.cards[idx].resource_path))
		return value_input
	
	func add_tag_input(name: String, value: StringName) -> OptionButton:
		var value_input = OptionButton.new()
		var current = 0
		for tag in Tags.known_tags:
			value_input.add_item(tag)
			if value != null and value == tag:
				value_input.select(current)
			current += 1
		var setter = add_control(name, value_input)
		value_input.item_selected.connect(
			func(idx):
				setter.call(Tags.known_tags[idx])
		)
		return value_input
	
	func add_effect_input(name: String, value: EffectResource) -> EditorEffectList:
		var value_input = EditorEffectList.new()
		var setter = add_control(name, value_input)
		return value_input

	func add_control(name: String, node: Control) -> Callable:
		parameter_inputs[name] = node
		return func(v): parameter_values[name] = v

var modifiable: bool = true:
	set(value):
		modifiable = value;
		_change_edition_possibility()
	get:
		return modifiable

var _proxy: Proxy

var _delete_icon = preload("res://art/trash_icon.svg")
var _script

func initialize(name: String, parameters: Dictionary, script: GDScript):
	_script = script
	
	var proxy: Proxy = Proxy.new(name)
	_script.build_editor_input(proxy, parameters)
	_effect_name.text = proxy.name
	for param in proxy.parameter_inputs:
		var name_label = Label.new()
		name_label.text = param 
		name_label.custom_minimum_size = Vector2(200, 0)
		_grid.add_child(name_label)
		_grid.add_child(proxy.parameter_inputs[param])
	_proxy = proxy
	return
			
func get_parameters() -> EffectResource:
	var resource = EffectResource.new()
	resource.effectScript = _script
	resource.effectValues = _proxy.parameter_values
	return resource


func _on_texture_button_pressed():
	deleted.emit()

func _change_edition_possibility():
	_delete_button.disabled = !modifiable
	for child in _grid.get_children():
		match child.get_class():
			SpinBox: 
				child.editable = !modifiable
	
