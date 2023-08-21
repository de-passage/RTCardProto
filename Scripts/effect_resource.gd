extends Resource

## This resource holds an effect (script) and the instance values 
## that are attached to it. It allows to have the same effect with 
## different intensities on different cards. 
class_name EffectResource

@export var effectValues: Dictionary
@export var effectScript: Script

func load_effect():
	if effectScript == null: 
		return DebugEffect.new("Effect Resource has no script attached!")
		
	var effect = effectScript.new(effectValues)
	if effect is BaseEffect: 
		if effect.has_method("accept_values"):
			effect.accept_values(effectValues)
		return effect
	else: 
		printerr("Failed to import effect!")
		return DebugEffect.new("Attached script is not an effect")
