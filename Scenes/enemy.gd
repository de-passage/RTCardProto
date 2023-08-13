extends Node2D

class_name Enemy

signal died
signal attacking

@export var max_hp: int: 
	set(value): 
		max_hp = value
		
@export var attack_frequency : float:
	set(value):
		$Control/EnergyBar.fill_time = value
		attack_frequency = value

var entity: PlayableEntity

func _ready(): 
	entity = PlayableEntity.new(max_hp)
	$Control/Health.connect_playable_entity(entity)

func _on_energy_bar_filled():
	attack()
	$Control/EnergyBar.reset_energy()

func attack(): 
	attacking.emit()
