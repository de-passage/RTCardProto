extends RefCounted

class_name Context

var source: PlayableEntity
var target: PlayableEntity
var current_card: CardGameInstance
var _card_effect: int = FORCE_DISCARD

const NO_EFFECT = 0

# What to do with the card after playing
const EXHAUST_CARD = 1 # Send to exhaust pile
const DESTROY_CARD = 1 << 1 # Remove from meta deck
const FORCE_DISCARD = 1 << 2 # Send the card to the discard

const TRASH_HAND = 1
const TRASH_DISCARD = 1 << 1
const TRASH_DRAW = 1 << 2
const CURSE = 1 << 3

static func create(card_: CardGameInstance, source_: PlayableEntity, target_: PlayableEntity):
	var ctx: Context = Context.new()
	ctx.source = source_
	ctx.current_card = card_
	ctx.target = target_
	return ctx

static func source_only(source_: PlayableEntity) -> Context: 
	return Context.create(null, source_, null)
	
static func on_draw_context(source_: PlayableEntity) -> Context:
	var c = Context.source_only(source_)
	c.remove_card_effect(FORCE_DISCARD)
	return c

func add_card_effect(e: int): 
	_card_effect |= e
	
func remove_card_effect(e: int):
	_card_effect &= ~e

func set_card_effect(e: int):
	_card_effect = e

func _effect_flag_set(e: int) -> bool:
	return (_card_effect & e) > 0
	
func exhaust_required() -> bool:
	return _effect_flag_set(EXHAUST_CARD)

func discard_required() -> bool:
	return _effect_flag_set(FORCE_DISCARD)
	
func purge_required() -> bool:
	return _effect_flag_set(DESTROY_CARD)

func trash(_what: CardGameInstance, _where: int = TRASH_DISCARD) -> void: 
	pass
	
func get_hand() -> Array[CardResource]:
	return []
	

