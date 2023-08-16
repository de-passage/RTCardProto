@tool
extends GridContainer
class_name EffectEditor

signal deleted

@onready var _effect_name = $BoxContainer/MarginContainer/HBoxContainer/EffectName
@onready var _grid = $GridContainer as GridContainer

var _values = []
var _delete_icon = preload("res://art/trash_icon.svg")
var _id = 0
var _script

func initialize(name: String, parameters: Array, script: GDScript):
	_effect_name.text = name 
	_script = script
	for param in parameters: 
		var label = Label.new()
		var value_name = param.get("name", "<unnamed value>")
		label.text = value_name
		label.custom_minimum_size = Vector2(200, 0)
		_grid.add_child(label)
		
		var type = param.get("type", "int")
		if type == "int":
			var value_input = SpinBox.new()
			_grid.add_child(value_input)
			value_input.min_value = param.get("min", 0)
			value_input.max_value = param.get("max", int(pow(2, 61)))
			var default = param.get("default", 1)
			value_input.value = default
			_values.append({ "value": default, "name": value_name})
			value_input.value_changed.connect(func(value):
				_values[_id].value = value
			)
			

func get_parameters() -> EffectResource:
	var resource = EffectResource.new()
	resource.effectScript = _script
	resource.effectValues = {}
	for v in _values:
		resource.effectValues[v.name] = v.value
	return resource


func _on_texture_button_pressed():
	deleted.emit()
