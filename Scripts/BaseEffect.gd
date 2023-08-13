class_name BaseEffect 

@export var description: String = "Does nothing"

func apply_effect(_player: PlayableEntity, _enemy: PlayableEntity) -> void: 
	pass
	
func get_description(_player: PlayableEntity) -> String: 
	return description
