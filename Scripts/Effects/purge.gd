extends BaseEffect

func _init(_parameters: Dictionary):
	self.description = "Purge"

func apply_effect(context: Context):
	context.add_card_effect(Context.DESTROY_CARD)

static func editor_name():
	return "Purge"

static func build_editor_input(_proxy: EffectEditor.Proxy, _params: Dictionary): 
	pass
