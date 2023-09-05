extends RefCounted

class_name BaseStatus

func get_name() -> StringName:
	return "Unnamed"

func get_value() -> int:
	return 0

func accept(_card: Card, _ctx: Context): 
	pass
