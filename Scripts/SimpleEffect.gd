extends BaseEffect
class_name SimpleEffect 

var effect_strength = 5
var modifier = null 
var targetProp = null 

func _init(v: Array[int], property: StringName, modif: Variant = null):
	if v.size() > 0: 
		effect_strength = v[0]
	targetProp = property

func _total_effect(p: PlayableEntity): 
	var total = effect_strength
	if modifier != null:
		total += p.get(modifier)
	return total

func apply_effect(player: PlayableEntity, _enemy: PlayableEntity): 
	player.set(targetProp, _total_effect(player) + player.get(targetProp))
	
func get_description(player: PlayableEntity): 
	return description % _total_effect(player)
