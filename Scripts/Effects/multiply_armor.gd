extends BaseEffect

var _multiplier = 0

func _init(v: Dictionary):
	_multiplier = v.get("Amount", 2)

func apply_effect(context: Context):
	context.source.armor *= _multiplier

func get_description(context: Context):
	return "Armor x%s (%s)" % [_multiplier, context.source.armor * _multiplier]

static func editor_name():
	return "Multiply armor"

static func build_editor_input(proxy: EffectEditor.Proxy, params: Dictionary):
	var amount = proxy.add_int_input(SimpleEffect.AMOUNT, params.get(SimpleEffect.AMOUNT, 2))
	amount.value = 2
	amount.min_value = 2
