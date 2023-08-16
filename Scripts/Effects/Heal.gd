extends SimpleEffect

@export var METADATA = {
	"name": "Heal",
	"parameters": [{
		"type": "int"
	}]
}

func _init(params: Dictionary):
	super._init(params, "current_hp", "heal_power")
	description = "Heal for %s HP"

static func get_metadata():
	return {
		"name": "Heal",
		"parameters": [{
			"type": "int",
			"name": "Amount",
			"min": 0
		}]
	}
