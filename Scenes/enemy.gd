extends Node2D

class_name Enemy

signal died(rewards: Dictionary)
signal effects(effect: Callable)

@onready var _sprite = $Sprite2D as Sprite2D
@onready var _energy_bar = $Control/EnergyBar as EnergyBar
@onready var _health_bar = $Control/Health as StatusSynopsis
@onready var _label = $Label as Label
@onready var _intent = $Control/Intent as Label
@onready var _energy_label = $Control/EnergyLabel as Label

var _resource: EnemyResource
var _entity: PlayableEntity

var _current_effect = 0
var _card_list: Array[CardGameInstance] = []
var _game_logic: Context

func initialize(entityResource: EnemyResource, player: PlayableEntity, game: Context):
	_resource = entityResource
	_game_logic = game
	
	_card_list.clear()
	var max_card_cost = 1
	for effect in _resource.effects:
		if effect != null:
			max_card_cost = max(max_card_cost, effect.cost)
			_card_list.append(CardGameInstance.from_resource(effect))
	
	_entity = PlayableEntity.new(_resource.health)
	_entity.died.connect(_on_entity_died)
	_entity.max_energy = max_card_cost
	_entity.energy = 0
	
	if _card_list.is_empty():
		_card_list.append(CardGameInstance.from_resource(preload("res://Cards/Enemy/weakattack.tres")))
	
	_sprite.texture = _resource.texture
	_sprite.material = _resource.shader
	
	_energy_bar.fill_time = _resource.attack_frequency
	_energy_bar.step_count = max_card_cost
	
	_energy_label.text = "%s / %s" % [ _entity.energy, _energy_bar._max_value() ]
	
	_health_bar.connect_playable_entity(_entity)
	_label.text = _resource.name

	show_intent(player)

func _on_energy_bar_filled():
	cast_effect()
	_energy_bar.reset_energy()

func cast_effect():
	if _card_list.size() <= _current_effect: return
	
	var card: CardGameInstance = _card_list[_current_effect];
	_current_effect = (_current_effect + 1) % _card_list.size()
	effects.emit(func(player): 
		_apply_card(player, card)
		show_intent(player))

func _apply_card(player: Player, card: CardGameInstance):
	_game_logic.source = _entity
	_game_logic.current_card = card
	_game_logic.target = player
	for effect in card.on_play():
		effect.apply_effect(_game_logic)

func show_intent(player: PlayableEntity):
	var text = ""
	
	if _current_effect >= _card_list.size() or \
		_card_list[_current_effect].on_play().size() == 0:
		text = "Lazying around"
	else:
		var card: CardGameInstance = _card_list[_current_effect]
		for effect in card.on_play():
			_game_logic.source = _entity
			_game_logic.current_card = card
			_game_logic.target = player
			text += effect.get_description(_game_logic)
		text += " (%s)" % card.energy_cost()
		
	_intent.text = text

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

func time_to_next() -> float: 
	return _energy_bar.time_to_next_step()


func _on_energy_bar_step_reached(step):
	_entity.energy = step
	_energy_label.text = "%s / %s" % [_entity.energy, _energy_bar._max_value()]
	
	var current_card = _card_list[_current_effect]
	var card_cost = max(current_card.energy_cost(), 1) # TODO this is wrong, but the monster cards are wrong too
	
	if _entity.energy >= card_cost:
		_entity.energy -= card_cost
		_energy_bar.deduct_energy(card_cost)
		cast_effect()
	
