extends BaseEffect
class_name DebugEffect

var _message;

func _init(msg: String):
	_message = msg

func apply_effect(_context: Context) -> void: 
	pass
	
func get_description(_context: Context) -> String: 
	return "Error: %s" % _message
