extends Control

signal health_changed(value: int)
signal died

@export var max_health: int
@export var current_health: int

func _display_health(): 
	$CurrentHealth.text = str(current_health) + '/' + str(max_health)

func _ready(): 
	_display_health() 

func set_health(h: int): 
	current_health = max(min(h, max_health), 0)
	health_changed.emit(current_health)
	if current_health == 0: 
		died.emit()

func damage(damage: int):
	set_health(current_health - damage)
	
func heal(restored: int):
	set_health(current_health + restored)
	
