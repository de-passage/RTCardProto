extends BaseEffect

var _count = 1

func _init(v: Dictionary):
	_count = v.get("Amount", 1)

func apply_effect(context: Context):
	context.require_draw(_count)

func get_description(_context: Context):
	return "Draw %s" % _count

static func editor_name():
	return "Draw"

static func get_metadata():
	return {
		"name": "Draw",
		"parameters": [
			{
				"name": "Amount",
				"type": "int",
				"min": 1
			}
		]
	}
