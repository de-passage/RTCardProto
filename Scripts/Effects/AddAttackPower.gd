extends SimpleEffect

func _init(v: Dictionary):
	super._init(v, "strength")
	description = "Gain %s attack power"

static func get_metadata():
	return {
		"name": "Add Strength",
		"parameters": [{
			"name": "Amount",
			"type": "int",
			"min": 1
		}]
	}
