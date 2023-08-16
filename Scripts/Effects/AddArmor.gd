extends SimpleEffect

func _init(v: Dictionary):
	super._init(v, "armor", "resistance")
	description = "Gain %s armor"

static func get_metadata():
	return {
	"name": "Add Armor",
	"parameters": [{
		"type": "int",
		"name": "Amount",
		"min": 1
		}]
	}
