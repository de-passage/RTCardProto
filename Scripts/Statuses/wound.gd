extends BaseStatus

class_name Wound

var _value = 1

func _init(value: int):
	_value = value

func get_name() -> StringName: 
	return "Wound"

func get_value() -> int:
	return _value
