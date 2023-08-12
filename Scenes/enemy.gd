extends Node2D

class_name Enemy

signal died
signal attacking

@export var max_hp: int: 
	set(value): 
		max_hp = value
		$Control/Health.max_health = max_hp
		$Control/Health.current_health = max_hp
		
@export var attack_frequency : float:
	set(value):
		$Control/EnergyBar.fill_time = value
		attack_frequency = value

func _on_energy_bar_filled():
	attack()
	$Control/EnergyBar.reset_energy()

func attack(): 
	attacking.emit()
	
func damage(value: int):
	$Control/Health.damage(value)


func _on_health_died():
	died.emit()
