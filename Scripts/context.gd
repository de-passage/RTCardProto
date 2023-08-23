extends RefCounted

class_name Context

var source: PlayableEntity
var target: PlayableEntity
var card: CardResource
var _card_effect: int = NO_EFFECT

const NO_EFFECT = 0
const EXHAUST_CARD = 1 # Send to exhaust pile
const DESTROY_CARD = 2 # Remove from meta deck
const FORCE_DISCARD = 4 # Send the card to the discard

func _init(card_: CardResource, source_: PlayableEntity, target_: PlayableEntity):
	source = source_
	card = card_
	target = target_

static func source_only(source_: PlayableEntity) -> Context: 
	return Context.new(null, source_, null)

func add_card_effect(e: int): 
	_card_effect |= e

func _effect_flag_set(e: int) -> bool:
	return (_card_effect & e) > 0
	
func exhaust_required() -> bool:
	return _effect_flag_set(EXHAUST_CARD)

func discard_required() -> bool:
	return _effect_flag_set(FORCE_DISCARD)
	
func purge_required() -> bool:
	return _effect_flag_set(DESTROY_CARD)
