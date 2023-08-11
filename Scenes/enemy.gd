extends Node2D

signal died
signal attacking

@export var max_hp = 10
@onready var current_hp = max_hp

func set_hp(value: int): 
	current_hp = max(min(max_hp, value), 0)
	$Health/Label.text = str(current_hp)
	if current_hp == 0: 
		died.emit()
		queue_free()
	
	
func deal_damage(value: int):
	set_hp(current_hp - value)
	


func _on_energy_bar_filled():
	attack()
	
func attack(): 
	attacking.emit()
	
