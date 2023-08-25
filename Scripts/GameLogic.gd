extends Context
class_name GameLogic

signal hand_changed(new_size: int)
signal discard_changed(new_size: int)
signal draw_pile_changed(new_size: int)
signal exhaust_changed(new_size: int)
signal card_played(card: CardResource)


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
			_add_to_hand(card)

## Play the given card on the enemy. This should probably use
## the local _player variable directly.
func play(played_card: CardResource, enemy: PlayableEntity):
	
	var idx = _hand.find(played_card)
	if idx >= 0:
		var card_from_hand = _hand.pop_at(idx)
		self.target = enemy
		self.set_card_effect(Context.FORCE_DISCARD)
		_handle_played_card(card_from_hand, card_from_hand.load_card_effects())
	else:
		printerr("Invalid card played!")

func discard(discarded_card: CardResource):
	var idx = _hand.find(discarded_card)
	if idx >= 0:
		var card_from_hand = _hand.pop_at(idx)
		self._player.mana += card_from_hand.cost
		self.set_card_effect(Context.FORCE_DISCARD)
		_handle_played_card(card_from_hand, card_from_hand.load_on_discard_card_effects())
	else:
		printerr("Invalid card discarded!")

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
		self.target = null
		_handle_played_card(drawn_card, effs)
	else:
		_add_to_hand(drawn_card)
	_draw_pile_changed()
	return true

func _handle_played_card(played: CardResource, effs: Array[BaseEffect]):
	self.current_card = played
	self.source = _player
	for e in effs:
		e.apply_effect(self)
	if purge_required():
		Global.remove_from_deck(played)
	elif exhaust_required():
		_add_to_exhaust(played)
	elif discard_required():
		_add_to_discard(played)
	else:
		_add_to_hand(played)
	card_played.emit(played)

func hand() -> Array[CardResource]: 
	return _hand

func player() -> Player:
	return _player

func trash(what: CardResource, where: int = TRASH_DISCARD) -> void:
	if (where & TRASH_DISCARD) > 0:
		_add_to_discard(what)
	if (where & TRASH_DRAW) > 0: 
		_add_to_draw_pile_randomly(what)
	if (where & TRASH_HAND) > 0: 
		if _hand.size() < HAND_SIZE:
			_add_to_hand(what)
		else:
			_add_to_draw_pile(what)
	if (where & CURSE) > 0:
		Global.add_to_current_deck(what)

func get_hand() -> Array[CardResource]:
	return _hand

func _add_to_draw_pile(card: CardResource):
	_draw_pile.append(card)
	_draw_pile_changed()
	
func _add_to_draw_pile_randomly(card: CardResource):
	_draw_pile.insert(randi_range(0, _draw_pile.size()), card)
	_draw_pile_changed()

func _add_to_hand(card: CardResource):
	_hand.append(card)
	_hand_changed()

func _add_to_exhaust(card: CardResource):
	_exhaust_pile.append(card)
	_exhaust_pile_changed()

func _add_to_discard(card: CardResource):
	_discard_pile.append(card)
	_discard_pile_changed()

func _draw_pile_changed():
	draw_pile_changed.emit(_draw_pile.size())
func _hand_changed():
	hand_changed.emit(_hand.size())
func _discard_pile_changed():
	discard_changed.emit(_discard_pile.size())
func _exhaust_pile_changed():
	exhaust_changed.emit(_exhaust_pile.size())
