extends BaseStatus

class_name Wound

var _value = 1

func _init(value: int):
	_value = value

func get_name() -> StringName: 
	return "Wound"

func get_value() -> int:
	return _value

func accept(card: Card, _ctx: Context): 
	card.change_cost(_value)
	card.add_description("Wound %s" % _value)
