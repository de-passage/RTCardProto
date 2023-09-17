extends SimpleEffect

func _init(v: Dictionary):
	super._init(v, "steady")
	description = "Gain %s steady"

static func editor_name():
	return "Add Steady"
