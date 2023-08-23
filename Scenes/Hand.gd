extends CanvasLayer
class_name HandManager

signal card_selected(card: CardResource)
signal draw_pile_changed(new_size: int)
signal discard_changed(new_size: int)
signal exhaust_changed(new_size: int)

# Visual constant
const SEPARATION = 35

# Resource management
var _card_scene: PackedScene = preload("res://Scenes/card.tscn")

# Game Logic
var _draw_pile: Array[CardResource]
var _discard_pile: Array[CardResource]
var _hand: Array[CardResource]
var _exhaust_pile: Array[CardResource]
var _player: PlayableEntity

const HAND_SIZE = 5

@onready var _hand_container = $HandContainer

# Creates the hand and so on
func initialize(deck: Array[CardResource], player_ref:PlayableEntity):
	_player = player_ref
	_draw_pile = deck.duplicate();
	_fill_hand()

# Build a new hand
func _show_hand():
	for child in _hand_container.get_children():
		if child is Card:
			child.queue_free()

	for card_resource in _hand:
		var card: Card = _card_scene.instantiate()
		_hand_container.add_child(card)
		card.initialize(card_resource, _player)
		card.scale = Vector2(1.,1.)
		card.selected.connect(_emit_selected.bind(card))

func _emit_selected(cardScene: Card):
	card_selected.emit(cardScene)

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
		else:
			_hand.append(card)
	
	
	_show_hand()

## Play the given card on the enemy. This should probably use
## the local _player variable directly.
func play(card: Card, player_: PlayableEntity, enemy: PlayableEntity):
	var context = Context.new(card._resource, player_, enemy)
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

	# Update card text
	for child in _hand_container.get_children():
		if child is Card:
			child.update_description(context)

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
	draw_pile_changed.emit(_draw_pile.size())
	_show_hand()
	return true

func _handle_played_card(card: CardResource, ctx: Context):
	if ctx.exhaust_required():
		_exhaust_pile.append(card)
		exhaust_changed.emit(_exhaust_pile.size())
	else:
		_discard_pile.append(card)
		discard_changed.emit(_discard_pile.size())
