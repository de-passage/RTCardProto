extends Node

const WOUND: StringName = "Wound"

#var _statuses: Dictionary
#const STATUSES_PATH = 'res://Scripts/Statuses'
#
#func load_statuses(): 
#	if _statuses.is_empty(): 
#		CGResourceManager.load_resources(STATUSES_PATH, func(r): 
#			if r is BaseStatus:
#				print("Loaded: %s" % r.get_name())
#				)

func wound(value: int) -> BaseStatus:
	return Wound.new(value)
