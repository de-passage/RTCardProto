extends SimpleEffect

func _init(v: Dictionary):
	super._init(v, "off_balance", null)
	description = "%s Off Balance"

static func get_metadata():
	return {
	"name": "Off Balance",
	"parameters": [{
		"type": "int",
		"name": "Amount",
		"min": 1
		}]
	}
