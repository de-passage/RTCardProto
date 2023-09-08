extends BaseEffect

var _count = 1

func _init(v: Dictionary): 
	_count = v.get("Amount", 1)

func apply_effect(context: Context):
	context.require_draw(_count)
	
func get_description(context: Context):
	return "Draw %s"
