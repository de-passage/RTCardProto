extends BaseEffect

func _init(_parameters: Dictionary):
	self.description = "Exhaust"

func apply_effect(context: Context):
	context.add_card_effect(Context.EXHAUST_CARD)

static func editor_name():
	return "Exhaust"
