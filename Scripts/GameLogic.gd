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
			var ctx = Context.source_only(_player)
			for e in effs:
				e.apply_effect(ctx)
			if ctx.purge_required():
				pass
			elif ctx.exhaust_required():
				_exhaust_pile.append(card)
				exhaust_changed.emit(_exhaust_pile.size())
			elif ctx.discard_required():
				_discard_pile.append(card)
				discard_changed.emit(_discard_pile.size())
			else:
				_hand.append(card)
				hand_changed.emit(_hand.size())
		else:
			_hand.append(card)
			hand_changed.emit(_hand.size())

## Play the given card on the enemy. This should probably use
## the local _player variable directly.
func play(card: Card, enemy: PlayableEntity):
	var context = Context.create(card._resource, _player, enemy)
	for effect in card.get_effects():
		if effect is BaseEffect:
			effect.apply_effect(context)
		
	var idx = _hand.find(card._resource)
	if idx >= 0:
		var card_from_hand = _hand.pop_at(idx)
		_handle_played_card(card_from_hand, context)
		card.queue_free()
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
	var ctx = Context.source_only(_player)
	var effs = drawn_card.load_on_draw_card_effects()
	if effs.size() > 0: 
		for effect in effs:
			effect.apply_effect(ctx)
		_handle_played_card(drawn_card, ctx)
	else:
		_hand.append(drawn_card)
		hand_changed.emit(_hand.size())
	draw_pile_changed.emit(_draw_pile.size())
	return true

func _handle_played_card(card: CardResource, ctx: Context):
	if ctx.exhaust_required():
		_exhaust_pile.append(card)
		exhaust_changed.emit(_exhaust_pile.size())
	else:
		_discard_pile.append(card)
		discard_changed.emit(_discard_pile.size())

func hand() -> Array[CardResource]: 
	return _hand

func player() -> Player:
	return _player
