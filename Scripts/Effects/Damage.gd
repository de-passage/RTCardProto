extends SimpleEffect

func _init(v: Dictionary): 
	super._init(v, "current_hp", "strength")
	description = "Deal %s damage"

func apply_effect(player: PlayableEntity, enemy: PlayableEntity): 
	enemy.deal_damage(_total_effect(player))

static func get_metadata():
	return {
		"name": "Deal damage",
		"parameters": [{
			"name": "Amount",
			"type": "int",
			"min": 0
		}]
	}
