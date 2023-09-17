extends SimpleEffect

func _init(v: Dictionary):
	super._init(v, "strength")
	description = "Gain %s attack power"

static func editor_name():
	return "Add strength"
