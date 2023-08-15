extends Node2D

class_name Enemy

signal died(rewards: Dictionary)
signal effects(effect: Callable)

var _resource: EnemyResource
var _entity: PlayableEntity

var current_effect = 0
var effectQueue: Array[BaseEffect] = [BaseEffect.new()]

func initialize(entityResource: EnemyResource):
	_resource = entityResource
	
	_entity = PlayableEntity.new(_resource.health)
	_entity.died.connect(_on_entity_died)
	
	effectQueue = []
	for effect in _resource.effects:
		effectQueue.append(effect.load_effect())
	if effectQueue.is_empty(): # Just so it doesn't crash with inert enemy
		effectQueue.append(BaseEffect.new())
	
	$Sprite2D.texture = _resource.texture
	$Sprite2D.material = _resource.shader
	$Control/EnergyBar.fill_time = _resource.attack_frequency
	$Control/Health.connect_playable_entity(_entity)
		

	show_intent()

func _on_energy_bar_filled():
	cast_effect()
	$Control/EnergyBar.reset_energy()

func cast_effect():
	var effect: BaseEffect = effectQueue[current_effect];
	effects.emit(func(player): effect.apply_effect(_entity, player))
	current_effect = (current_effect + 1) % effectQueue.size()
	show_intent()

func show_intent(): 
	$Control/Intent.text = effectQueue[current_effect].get_description(_entity)

func get_entity() -> PlayableEntity:
	return _entity

func _on_entity_died():
	var rewards = {
		Global.REWARD_COINS: _resource.coin_value,
		Global.REWARD_CARD: false,
		Global.REWARD_RELIC: null,
		Global.REWARD_POTION: null
	}
	died.emit(rewards)
