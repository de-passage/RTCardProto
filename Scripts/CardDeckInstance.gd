extends Resource

class_name CardDeckInstance

var _base_card: CardResource

var _name: String
var _on_play: Array[BaseEffect]
var _on_exhaust: Array[BaseEffect]
var _on_discard: Array[BaseEffect]
var _on_draw: Array[BaseEffect]
var _statuses: Array[BaseStatus]
var _energy_cost: int
var _mana_cost: int

func _init(card: CardResource):
	_base_card = card
	_name = card.card_name
	_on_play = card.load_card_effects()
	_on_exhaust = card.load_on_exhaust_card_effects()
	_on_discard = card.load_on_exhaust_card_effects()
	_on_draw = card.load_on_draw_card_effects()
	_energy_cost = card.cost
	_mana_cost = card.mana_cost

func on_play() -> Array[BaseEffect]:
	return _on_play

func on_exhaust() -> Array[BaseEffect]:
	return _on_exhaust
	
func on_discard() -> Array[BaseEffect]:
	return _on_discard
	
func on_draw() -> Array[BaseEffect]:
	return _on_draw

func energy_cost() -> int: 
	return _energy_cost

func mana_cost() -> int: 
	return _mana_cost

func card_name() -> String:
	return _name

func tags() -> Array[StringName]:
	return _base_card.tags

func playable() -> bool: 
	return _base_card.playable

func get_resource() -> CardResource: 
	return _base_card

func add_status(value: BaseStatus):
	_statuses.append(value)
