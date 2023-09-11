extends BaseEffect

var _value = 1

func _init(v: Dictionary):
	_value = v.get("Amount", 1)

func get_description(_context: Context):
	return "%s Off Balance" % _value
	
func apply_effect(context: Context): 
	context.target.energy -= _value

static func get_metadata():
	return {
	"name": "Off Balance",
	"parameters": [{
		"type": "int",
		"name": "Amount",
		"min": 1
		}]
	}
