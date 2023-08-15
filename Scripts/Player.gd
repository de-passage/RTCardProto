class_name Player
extends PlayableEntity

func _init(current, max_val):
	super._init(max_val)
	current_hp = current
