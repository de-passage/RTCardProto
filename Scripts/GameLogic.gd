extends Context
class_name GameLogic

const DRAW_COST = 1

signal hand_changed(new_size: int)
signal discard_changed(new_size: int)
signal draw_pile_changed(new_size: int)
signal exhaust_changed(new_size: int)

signal card_played(card: CardGameInstance)
signal not_enough_energy(card: CardGameInstance, player_energy: int)
signal not_enough_mana(card : CardGameInstance, player_mana: int)

signal discard_failed(card: CardDeckInstance)
signal card_discarded(card: CardGameInstance)

signal card_exhausted(card: CardGameInstance)
signal card_added_to_hand(card: CardGameInstance)
signal card_added_to_draw(card: CardGameInstance)
signal card_added_to_discard(card: CardGameInstance)

# Game Logic
var _draw_pile: Array[CardGameInstance]
var _discard_pile: Array[CardGameInstance]
var _hand: Array[CardGameInstance]
var _exhaust_pile: Array[CardGameInstance]
var _player: Player
var _history: History = History.new()

const HAND_SIZE = 5

func initialize(pl: Player, draw: Array[CardDeckInstance]):
	_player = pl
	_player._ctx = self
	
	card_played.connect(_player.card_played)
	
	source = pl
	_draw_pile = []
	for card in draw: 
		var goes_to_discard = false
		for s in card.statuses():
			if s.get_name() == Statuses.WOUND: 
				goes_to_discard = true
		
		var game_instance = CardGameInstance.new(card)
		if goes_to_discard:
			_discard_pile.append(game_instance)
		else:
			_draw_pile.append(game_instance)
	_fill_hand()
	
	if _discard_pile.size() > 0: 
		_discard_pile_changed()


## Shuffle the draw pile then draw until the hand is full
## Redraw the _hand afterwards
func _fill_hand():
	_draw_pile.shuffle()
	var need_to_draw = HAND_SIZE - _hand.size()
	var idx_in_draw_pile = _draw_pile.size() - need_to_draw
	var drawn_cards: Array[CardGameInstance] = _draw_pile.slice(idx_in_draw_pile)
	_draw_pile = _draw_pile.slice(0, idx_in_draw_pile)
	draw_pile_changed.emit(_draw_pile.size())
	
	for card in drawn_cards:
		_history.card_drawn(card)
		var effs = card.on_draw()
		if effs.size() > 0:
			_handle_played_card(card, effs)
		else:
			_add_to_hand(card)

## Play the given card on the enemy. This should probably use
## the local _player variable directly.
func play(played_card: CardGameInstance, enemy: PlayableEntity) -> bool:
		
	var idx = _hand.find(played_card)
	if idx >= 0:
		var card_from_hand = _hand.pop_at(idx)
		self.target = enemy
		self.set_card_effect(Context.FORCE_DISCARD)
		_handle_played_card(card_from_hand, card_from_hand.on_play())
		return true
	else:
		printerr("Invalid card played!")
		return false

func discard(discarded_card: CardDeckInstance) -> bool:
	if not discarded_card.playable():
		discard_failed.emit(discarded_card)
		return false
	
	var idx = _hand.find(discarded_card)
	if idx >= 0:
		var card_from_hand = _hand.pop_at(idx)
		_history.card_discarded(card_from_hand)
		self._player.mana += 2
		self.set_card_effect(Context.FORCE_DISCARD)
		
		_handle_played_card(card_from_hand, card_from_hand.on_discard())
	else:
		printerr("Invalid card discarded!")
		return false
	return true
	
## Draw one new card. If the draw pile is empty, shuffle the discard
## in the draw pile then draw. Fails if max hand size is reached
func draw_one_card() -> bool:
	if _hand.size() >= HAND_SIZE:
		return false

	if _draw_pile.size() == 0:
		_draw_pile.append_array(_discard_pile)
		_draw_pile.shuffle()
		_discard_pile.clear()
		discard_changed.emit(_discard_pile.size())

	if _draw_pile.size() == 0:
		return false

	var drawn_card: CardGameInstance = _draw_pile.pop_back()
	_history.card_drawn(drawn_card)
	var effs = drawn_card.on_draw()
	if effs.size() > 0: 
		self.set_card_effect(Context.NO_EFFECT)
		self.target = null
		_handle_played_card(drawn_card, effs)
	else:
		_add_to_hand(drawn_card)
	_draw_pile_changed()
	return true

## Draw from the deck iff the player has enough energy 
func draw_requested() -> bool:
	if _player.energy >= DRAW_COST and draw_one_card():
		_player.energy -= DRAW_COST
		return true
	return false
	
func _handle_played_card(played: CardGameInstance, effs: Array[BaseEffect]):
	self.current_card = played
	self.source = _player
	for e in effs:
		e.apply_effect(self)
	
	var draw_required = required_draw()
	
	if effs.size() > 0: 
		_history.card_played(played)
	
	if purge_required():
		_history.card_purged(played)
		Global.remove_from_deck(played.source_instance())
	elif exhaust_required():
		_add_to_exhaust(played)
	elif discard_required():
		_add_to_discard(played)
	else:
		_add_to_hand(played)
	card_played.emit(played)
	
	for x in range(0, draw_required):
		draw_one_card()

func player() -> Player:
	return _player

## Add a new card to the given positions
func trash(what: CardGameInstance, where: int = TRASH_DISCARD) -> void:
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
		Global.add_to_current_deck(what.source_instance())


func hand() -> Array[CardGameInstance]:
	return _hand

func draw_pile() -> Array[CardGameInstance]:
	return _draw_pile
	
func discard_pile() -> Array[CardGameInstance]:
	return _discard_pile

func exhaust_pile() -> Array[CardGameInstance]:
	return _exhaust_pile

## Add card to top of draw pile and send the relevant events
func _add_to_draw_pile(card: CardGameInstance):
	_draw_pile.append(card)
	card_added_to_draw.emit(card)
	_draw_pile_changed()
	
## Add card to random position in draw pile and send the relevant events
func _add_to_draw_pile_randomly(card: CardGameInstance):
	_draw_pile.insert(randi_range(0, _draw_pile.size()), card)
	card_added_to_draw.emit(card)
	_draw_pile_changed()

## Add card to hand and send the relevant events
func _add_to_hand(card: CardGameInstance):
	_hand.append(card)
	if _hand.size() == HAND_SIZE:
		var dead = true
		for c in _hand: 
			if c.playable():
				dead = false
				break
		if dead:
			_player.current_hp = 0
			return
		
	card_added_to_hand.emit(card)
	_hand_changed()

## Add card to exhaust pile and send the relevant events
func _add_to_exhaust(card: CardGameInstance):
	_exhaust_pile.append(card)
	_history.card_exhausted(card)
	card_exhausted.emit(card)
	_exhaust_pile_changed()

## Add card to discard pile and send the relevant events
func _add_to_discard(card: CardGameInstance):
	_discard_pile.append(card)
	_history.card_discarded(card)
	card_discarded.emit(card)
	_discard_pile_changed()

## Emit the new draw size
func _draw_pile_changed():
	draw_pile_changed.emit(_draw_pile.size())

## Emit the new hand size
func _hand_changed():
	hand_changed.emit(_hand.size())

## Emit the new discard size
func _discard_pile_changed():
	discard_changed.emit(_discard_pile.size())

## Emit the new exhaust size
func _exhaust_pile_changed():
	exhaust_changed.emit(_exhaust_pile.size())

func history() -> History:
	return _history
