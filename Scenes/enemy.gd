extends Node2D

class_name Enemy

signal died
signal effects(effect: Callable)

@export var max_hp: int: 
	set(value): 
		max_hp = value
		
@export var attack_frequency : float:
	set(value):
		$Control/EnergyBar.fill_time = value
		attack_frequency = value

@export var effectList: Array[EffectResource] = []

@onready var entity = PlayableEntity.new(max_hp)

@export var coin_value = 13
var current_effect = 0
var effectQueue: Array[BaseEffect] 

func _ready(): 
	$Control/Health.connect_playable_entity(entity)
	for effect in effectList:
		effectQueue.append(effect.load_effect())
		
	if effectQueue.is_empty(): # Just so it doesn't crash
		effectQueue.append(BaseEffect.new())
	
	show_intent()

func _on_energy_bar_filled():
	cast_effect()
	$Control/EnergyBar.reset_energy()

func cast_effect():
	var effect: BaseEffect = effectQueue[current_effect];
	effects.emit(func(player): effect.apply_effect(entity, player))
	current_effect = (current_effect + 1) % effectQueue.size()
	show_intent()

func show_intent(): 
	$Control/Intent.text = effectQueue[current_effect].get_description(entity)
