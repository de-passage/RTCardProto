extends SimpleEffect

@export var effect_strength = 1

func _init(v: Array[int]):
	super._init(v, "strength")
	description = "Gain %s attack power"
