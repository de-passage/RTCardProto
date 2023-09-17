extends BaseEffect

var _value = 1

func _init(v: Dictionary):
	_value = v.get("Amount", 1)

func get_description(_context: Context):
	return "%s Off Balance" % _value

func apply_effect(context: Context):
	context.target.energy -= _value

static func editor_name():
	return "Off Balance"

static func build_editor_input(proxy: EffectEditor.Proxy, parameters: Dictionary):
	pass
