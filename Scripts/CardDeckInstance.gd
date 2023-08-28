extends Resource

class_name CardDeckInstance

var _base_card: CardResource

var name: String
var on_play: Array[BaseEffect]
var on_exhaust: Array[BaseEffect]
var on_discard: Array[BaseEffect]
var on_draw: Array[BaseEffect]
var energy_cost: int
var mana_cost: int


func _init(card: CardResource):
	_base_card = card
	name = card.card_name
	on_play = card.load_card_effects()
	on_exhaust = card.load_on_exhaust_card_effects()
	on_discard = card.load_on_exhaust_card_effects()
	on_draw = card.load_on_draw_card_effects()
	energy_cost = card.cost
	mana_cost = card.mana_cost
