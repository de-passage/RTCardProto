extends BaseEffect

@export var effect_strength = 5

func _init():
	description = "Gain %s armor"
	
func _total_armor(p: PlayableEntity): 
	return effect_strength + p.resistance

func apply_effect(player: PlayableEntity, _enemy: PlayableEntity): 
	player.armor += _total_armor(player)
	
func get_description(player: PlayableEntity): 
	return description % _total_armor(player)
