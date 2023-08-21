extends SimpleEffect

func _init(v: Dictionary): 
	super._init(v, "current_hp", "strength")
	description = "Deal %s damage"

func apply_effect(context: Context):
	context.target.deal_damage(_total_effect(context.source))

static func get_metadata():
	return {
		"name": "Deal damage",
		"parameters": [{
			"name": "Amount",
			"type": "int",
			"min": 0
		}]
	}
