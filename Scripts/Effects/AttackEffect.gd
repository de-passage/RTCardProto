class_name AttackEffect
extends BaseEffect

@export var attack_value = 5

func _init(): 
	description = "Deal %s damage"

func _attack_strength(p: PlayableEntity):
	return attack_value + p.strength

func apply_effect(player: PlayableEntity, enemy: PlayableEntity): 
	enemy.deal_damage(_attack_strength(player))

func get_description(player: PlayableEntity): 
	return description % _attack_strength(player)
