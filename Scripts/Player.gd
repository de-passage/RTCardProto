class_name Player
extends PlayableEntity

var _ctx: Context
var _wound: CardResource = preload("res://Cards/wound.tres")

func _init(current, max_val, ctx: Context):
	super._init(max_val, current)
	_ctx = ctx

func deal_damage(damage: int) -> void: 
	var after_armor = armor - damage
	# Armor absorbs all the damage
	if after_armor >= 0: 
		armor = after_armor
	elif after_armor < 0:
		armor = 0
		add_wound(-after_armor) # we want a positive-valued wound

func _new_wound(value) -> CardGameInstance: 
	var wound = CardDeckInstance.new(_wound)
	wound.add_status(Statuses.wound(value))
	return CardGameInstance.new(wound)

func add_wound(value: int) -> void:
	if value > 10:
		died.emit()
		return
	
	var to_hand = 0
	if value > 5:
		to_hand = value - 5
		value = 5
		
		_ctx.trash(_new_wound(to_hand), Context.TRASH_HAND | Context.CURSE)
	
	_ctx.trash(_new_wound(value), Context.TRASH_DISCARD | Context.CURSE)

func card_played(card: CardGameInstance): 
	if card.has_tag(Tags.ATTACK):
		self.steady = 0
