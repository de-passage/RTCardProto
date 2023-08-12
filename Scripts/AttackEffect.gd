class_name AttackEffect
extends BaseEffect

@export var attack_value = 5

static func create(damage: int): 
	var this = AttackEffect.new()
	this.attack_value = damage

func apply_effect(player: Player, enemy: Enemy): 
	enemy.damage(attack_value + player.strength)

func modify_description(description: String, player: Player): 
	return description % (attack_value + player.strength)
