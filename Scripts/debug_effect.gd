extends BaseEffect
class_name DebugEffect

var _message;

func _init(msg: String):
	_message = msg

func apply_effect(_player: PlayableEntity, _enemy: PlayableEntity) -> void: 
	pass
	
func get_description(_player: PlayableEntity) -> String: 
	return "Error: %s" % _message
