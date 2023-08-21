## All effects must inherit from this to be picked by the Inspector
class_name BaseEffect

## Override in derived classes to provide description
@export var description = "Does nothing"

func apply_effect(_context: Context):
	pass
	
func get_description(_context: Context) -> String: 
	return description
