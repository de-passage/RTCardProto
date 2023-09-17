extends SimpleEffect

func _init(params: Dictionary):
	super._init(params, "current_hp", "heal_power")
	description = "Heal for %s HP"

static func editor_name():
	return "Heal"
