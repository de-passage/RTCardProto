class_name Player
extends PlayableEntity

var _ctx: Context
var _wound: CardResource = preload("res://Cards/wound.tres")

func _init(current, max_val, ctx: Context):
	super._init(max_val, current)
	_ctx = ctx
		
func wound(value: int):
	if value > 10:
		died.emit()
		return
	
	var to_hand = 0
	if value > 5:
		to_hand = value - 5
		value = 5
		
		_ctx.trash(_new_wound(to_hand), Context.TRASH_HAND | Context.CURSE)
	
	_ctx.trash(_new_wound(value), Context.TRASH_DISCARD | Context.CURSE)

func _new_wound(value) -> CardGameInstance: 
	var wound = CardDeckInstance.new(_wound)
	wound.add_status(Statuses.wound(value))
	return CardGameInstance.new(wound)

