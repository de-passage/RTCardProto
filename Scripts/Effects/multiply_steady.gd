extends BaseEffect

var _multiplier = 0

func _init(v: Dictionary): 
	_multiplier = v.get("Amount", 2)

func apply_effect(context: Context):
	context.source.steady *= _multiplier
	
func get_description(context: Context):
	return "Steady x%s (%s)" % [_multiplier, context.source.steady * _multiplier]

static func get_metadata():
	return {
		"name": "Multiply steady",
		"parameters": [
			{	
				"type": "int",
				"name": "Amount",
				"min": 1
			}
		]
	}
