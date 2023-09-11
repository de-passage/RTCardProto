extends SimpleEffect

func _init(v: Dictionary):
	super._init(v, "defense", "resistance")
	description = "Gain %s defense"

static func get_metadata():
	return {
	"name": "Add Defense",
	"parameters": [{
		"type": "int",
		"name": "Amount",
		"min": 1
		}]
	}
