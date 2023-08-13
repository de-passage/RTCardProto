extends SimpleEffect

func _init(v: Array[int]): 
	super._init(v, "current_hp", "strength")
	description = "Deal %s damage"

func apply_effect(player: PlayableEntity, enemy: PlayableEntity): 
	enemy.deal_damage(_total_effect(player))
