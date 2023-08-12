extends BaseEffect

@export var effect_strength = 5

func apply_effect(player: Player, _enemy: Enemy): 
	player.armor += effect_strength
	
func modify_description(desc: String, _player: Player):
	return desc % effect_strength
