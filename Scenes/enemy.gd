extends Node2D

class_name Enemy

signal died
signal effects(effect: Callable)

@export var max_hp: int: 
	set(value): 
		max_hp = value
		
@export var attack_frequency : float:
	set(value):
		attack_frequency = value

@export var effectList: Array[EffectResource] = []

@export var resource: EnemyResource:
	set(value):
		resource = value
		effectList = value.effects
		coin_value = value.coin_value
		max_hp = value.health
		attack_frequency = value.attack_frequency
		if $Sprite2D != null:
			$Sprite2D.texture = resource.texture
			$Sprite2D.material = resource.shader
		if $Control/EnergyBar != null:
			$Control/EnergyBar.fill_time = attack_frequency
		effectQueue = []
		for effect in effectList:
			effectQueue.append(effect.load_effect())
			
		if effectQueue.is_empty(): # Just so it doesn't crash
			effectQueue.append(BaseEffect.new())
			
		if $Control/Health != null:	
			$Control/Health.connect_playable_entity(entity)

@onready var entity = PlayableEntity.new(max_hp)

@export var coin_value = 13
var current_effect = 0
var effectQueue: Array[BaseEffect] 

func _ready():
	# This needs a rework. Basically depending on the situation
	# the resource may not be ready yet...
	if resource != null:
		resource = resource
	
	if attack_frequency <= 0: 
		attack_frequency = 5
	$Control/Health.connect_playable_entity(entity)
	
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
