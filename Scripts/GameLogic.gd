extends Context
class_name GameLogic

signal hand_changed(new_size: int)
signal discard_changed(new_size: int)
signal draw_pile_changed(new_size: int)
signal exhaust_changed(new_size: int)


# Game Logic
var _draw_pile: Array[CardResource]
var _discard_pile: Array[CardResource]
var _hand: Array[CardResource]
var _exhaust_pile: Array[CardResource]
var _player: Player

const HAND_SIZE = 5

func initialize(pl: Player, draw: Array[CardResource]):
	_player = pl
	source = pl 
	_draw_pile = draw
	_fill_hand()
	

## Shuffle the draw pile then draw until the hand is full
## Redraw the _hand afterwards
func _fill_hand():
	_draw_pile.shuffle()
	var need_to_draw = HAND_SIZE - _hand.size()
	var idx_in_draw_pile = _draw_pile.size() - need_to_draw
	var drawn_cards: Array[CardResource] = _draw_pile.slice(idx_in_draw_pile)
	_draw_pile = _draw_pile.slice(0, idx_in_draw_pile)
	draw_pile_changed.emit(_draw_pile.size())
	
	for card in drawn_cards:
		var effs = card.load_on_draw_card_effects()
		if effs.size() > 0:
			_handle_played_card(card, effs)
		else:
			_hand.append(card)
			hand_changed.emit(_hand.size())

## Play the given card on the enemy. This should probably use
## the local _player variable directly.
func play(played_card: Card, enemy: PlayableEntity):
	self.current_card = played_card._resource
	self.target = enemy
	self.set_card_effect(Context.FORCE_DISCARD)
		
	var idx = _hand.find(played_card._resource)
	if idx >= 0:
		var card_from_hand = _hand.pop_at(idx)
		_handle_played_card(card_from_hand, card_from_hand.load_card_effects())
		played_card.queue_free()
	else:
		printerr("Invalid card played!")


## Draw one new card. If the draw pile is empty, shuffle the discard
## in the draw pile then draw. Fails if max hand size is reached
func draw_one_card() -> bool:
	if _hand.size() >= HAND_SIZE:
		return false

	if _draw_pile.size() == 0:
		_draw_pile.append_array(_discard_pile)
		_discard_pile.clear()
		discard_changed.emit(_discard_pile.size())

	if _draw_pile.size() == 0:
		return false

	var drawn_card: CardResource = _draw_pile.pop_back()
	var effs = drawn_card.load_on_draw_card_effects()
	if effs.size() > 0: 
		self.set_card_effect(Context.NO_EFFECT)
		_handle_played_card(drawn_card, effs)
	else:
		_hand.append(drawn_card)
		hand_changed.emit(_hand.size())
	draw_pile_changed.emit(_draw_pile.size())
	return true

func _handle_played_card(played: CardResource, effs: Array[BaseEffect]):
	for e in effs:
		e.apply_effect(self)
	if purge_required():
		pass
	elif exhaust_required():
		_exhaust_pile.append(played)
		exhaust_changed.emit(_exhaust_pile.size())
	elif discard_required():
		_discard_pile.append(played)
		discard_changed.emit(_discard_pile.size())
	else:
		_hand.append(played)
		hand_changed.emit(_hand.size())

func hand() -> Array[CardResource]: 
	return _hand

func player() -> Player:
	return _player
