extends Node2D

class_name Enemy

signal died(rewards: Dictionary)
signal effects(effect: Callable)

var _resource: EnemyResource
var _entity: PlayableEntity

var current_effect = 0
var _card_list: Array[CardResource] = []

func initialize(entityResource: EnemyResource):
	_resource = entityResource
	
	_entity = PlayableEntity.new(_resource.health)
	_entity.died.connect(_on_entity_died)
	
	_card_list.clear()
	for effect in _resource.effects:
		if effect != null:
			_card_list.append(effect)
	
	$Sprite2D.texture = _resource.texture
	$Sprite2D.material = _resource.shader
	$Control/EnergyBar.fill_time = _resource.attack_frequency
	$Control/Health.connect_playable_entity(_entity)
	$Label.text = _resource.name

	show_intent()

func _on_energy_bar_filled():
	cast_effect()
	$Control/EnergyBar.reset_energy()

func cast_effect():
	if _card_list.size() <= current_effect: return
	
	var card: CardResource = _card_list[current_effect];
	effects.emit(func(player): _apply_card(player, card))
	current_effect = (current_effect + 1) % _card_list.size()
	show_intent()

func _apply_card(player: Player, card: CardResource):
	for effect in card.cardEffects:
		effect.load_effect().apply_effect(_entity, player)

func show_intent():
	var text = ""
	
	if current_effect >= _card_list.size() or \
		_card_list[current_effect].cardEffects.size() == 0:
		text = "Lazying around"
	else:
		for effect in _card_list[current_effect].load_card_effects():
			text += effect.get_description(_entity)
	
	$Control/Intent.text = text 

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
