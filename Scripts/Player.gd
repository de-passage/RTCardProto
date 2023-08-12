class_name Player

signal armor_added(value: int)

@export var strength: int = 0: 
	set(value): 
		strength = value
		
@export var armor: int = 0:
	set(value): 
		var last_armor = armor
		armor = value
		armor_added.emit(value - last_armor)
