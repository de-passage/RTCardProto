extends SimpleEffect

func _init(v: Dictionary):
	super._init(v, "steady")
	description = "Gain %s steady"

static func get_metadata():
	return {
		"name": "Add Steady",
		"parameters": [{
			"name": "Amount",
			"type": "int",
			"min": 1
		}]
	}
