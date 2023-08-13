## All effects must inherit from this to be picked by the Inspector
class_name BaseEffect

@export var description: String = "Does nothing"

func apply_effect(_player: PlayableEntity, _enemy: PlayableEntity) -> void: 
	pass
	
func get_description(_player: PlayableEntity) -> String: 
	return description
