extends SimpleEffect

func _init(v: Dictionary):
	super._init(v, "armor", "resistance")
	description = "Gain %s armor"

static func editor_name():
	return "Gain Armor"
