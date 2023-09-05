extends Object

class_name PlayableEntity

signal died
signal max_hp_changed(new_value: int)
signal current_hp_changed(new_value: int)
signal armor_changed(new_value: int)
signal strength_changed(new_value: int)
signal heal_power_changed(new_value: int)
signal resistance_changed(new_value: int)
signal mana_changed(new_value: int)
signal energy_changed(new_value: int)

## Maximum amount of HP an entity may have
var max_hp: int = 1:
	set(value):
		max_hp = max(0, value)
		max_hp_changed.emit(value)
		if max_hp < current_hp: 
			current_hp = max_hp

## Current amount of HP the entity has 
var current_hp: int = 1:
	set(value):
		current_hp = max(0, min(value, max_hp))
		current_hp_changed.emit(value)
		if current_hp == 0: 
			died.emit()

## Current amount of armor the entity has 
var armor: int = 0:
	set(value):
		armor = max(0, value)
		armor_changed.emit(value)

## Flat modifier on damage effects
var strength: int = 0: 
	set(value):
		strength = value
		strength_changed.emit(value)

## Flat modifier on healing effects
var heal_power: int = 0:
	set(value):
		heal_power = value
		heal_power_changed.emit(value)

## Flat modifier on armor increases
var resistance: int = 0:
	set(value):
		resistance = value
		resistance_changed.emit(value)

## Available mana
var mana: int = 0: 
	set(value):
		mana = value
		mana_changed.emit(value)

## Available energy
var energy: int = 0:
	set(value):
		energy = value
		energy_changed.emit(value)

func _init(max_health: int, current_health: int = -1):
	max_hp = max_health
	current_hp = current_health if current_health > 0 else max_health

## Deal damage to the entity, reducing armor then HP. 
## Manipulate current_hp directly to ignore armor
func deal_damage(damage: int): 
	var after_armor = armor - damage;
	# Armor absorbs all the damage
	if after_armor >= 0: 
		armor = after_armor
	elif after_armor < 0:
		armor = 0
		current_hp += after_armor

