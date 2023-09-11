extends BaseEffect

func _init(_v: Dictionary): 
	pass

func apply_effect(context: Context):
	context.source.attack(context.target, _effect_value(context))

func get_description(context: Context):
	return "Deal as much damage as you have armor (%s)" % _effect_value(context)

static func get_metadata():
	return {
		"name": "Deal damage equal to block",
		"parameters": []
	}

func _effect_value(context: Context):
	return context.source.armor + context.source.strength
