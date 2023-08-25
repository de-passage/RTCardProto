extends BaseEffect

func _init(_parameters: Dictionary):
	self.description = "Purge"

func apply_effect(context: Context):
	context.add_card_effect(Context.DESTROY_CARD)

static func get_metadata():
	return {
		"name": "Purge",
		"parameters": []
	}
