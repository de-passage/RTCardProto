extends SimpleEffect

func _init(params: Array[int]):
	super._init(params, "current_hp", "heal_power")
	description = "Heal for %s HP"
