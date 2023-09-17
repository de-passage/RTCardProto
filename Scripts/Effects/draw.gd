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

static func build_editor_input(proxy: EffectEditor.Proxy, params: Dictionary):
	proxy.add_int_input(SimpleEffect.AMOUNT, params.get(SimpleEffect.AMOUNT, 1))
