extends SimpleEffect

func _init(v: Dictionary):
	super._init(v, "defense", "resistance")
	description = "Gain %s defense"

static func editor_name():
	return "Add Defense"
