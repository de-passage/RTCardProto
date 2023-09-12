extends ValueDisplay

class_name ValueDisplayWithMax

@export var max_value: int = 0

func _set_text(): 
	_label.text = "%s/%s" % [ value, max_value ]

func set_max_value(v: int): 
	max_value = v
