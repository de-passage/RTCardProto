extends BaseEffect

## Base class for simple effects modifying a characteristic based on 
## the base value of the effect added to a modifier
class_name SimpleEffect

var effect_strength = 5
var modifier = null 
var targetProp = null 

## The two input properties should be the name of the characteristic that is 
## modified by the effect, followed by the name of the modifying characteristic
##
## For example, a heal effect would give in first property name "current_hp" 
## and in second "heal_power"
func _init(v: Dictionary, property: StringName, modif: Variant = null):
	if v.size() > 0: 
		effect_strength = v.get("Amount")
	targetProp = property
	modifier = modif

func _total_effect(p: PlayableEntity): 
	var total = effect_strength
	if modifier != null and p != null:
		total += p.get(modifier)
	return total

func apply_effect(context: Context):
	context.source.set(targetProp, _total_effect(context.source) + context.source.get(targetProp))
	
func get_description(context: Context): 
	return description % _total_effect(context.source)
