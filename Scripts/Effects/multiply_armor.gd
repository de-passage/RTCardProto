extends BaseEffect

var _multiplier = 0

func _init(v: Dictionary): 
	_multiplier = v.get("Amount", 2)

func apply_effect(context: Context):
	context.source.armor *= _multiplier
	
func get_description(context: Context):
	return "Armor x%s (%s)" % [_multiplier, context.source.armor * _multiplier]
