class_name Player

signal attribute_changed

@export var strength: int = 0: 
	set(value): 
		strength = value
		attribute_changed.emit() 
		
@export var armor: int = 0:
	set(value): 
		armor = value
		attribute_changed.emit()
