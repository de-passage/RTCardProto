extends BaseEffect

func _init(_parameters: Dictionary):
	self.description = "Exhaust"

func apply_effect(context: Context):
	context.add_card_effect(Context.EXHAUST_CARD)

static func editor_name():
	return "Exhaust"

static func build_editor_input(_p: EffectEditor.Proxy, _d: Dictionary):
	pass
