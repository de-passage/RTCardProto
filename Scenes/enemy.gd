extends Node2D

signal died
signal attacking

@export var max_hp = 10
@export var attack_frequency : float:
	set(value):
		$EnergyBar.fill_time = value
		attack_frequency = value
		
@onready var current_hp = max_hp

func _on_energy_bar_filled():
	attack()
	$Control/EnergyBar.reset_energy()

func attack(): 
	attacking.emit()
