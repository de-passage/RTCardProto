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

const HAND_SIZE = 4

@onready var _hand_container = $HandContainer

# Creates the hand and so on
func initialize(deck: Array[CardResource], player_ref:PlayableEntity):
	_draw_pile = deck.duplicate();
	fill_hand()
	_player = player_ref

# Build a new hand
func _show_hand():
	for child in _hand_container.get_children():
		if child is Card:
			child.queue_free()

	for card_resource in _hand:
		var card: Card = _card_scene.instantiate()
		card.initialize(card_resource, _player)
		card.scale = Vector2(1.,1.)
		card.selected.connect(_emit_selected.bind(card))
		_hand_container.add_child(card)

func _emit_selected(cardScene: Card):
	card_selected.emit(cardScene)

## Shuffle the draw pile then draw until the hand is full
## Redraw the _hand afterwards
func fill_hand():
	_draw_pile.shuffle()
	var need_to_draw = HAND_SIZE - _hand.size()
	var idx_in_draw_pile = _draw_pile.size() - need_to_draw
	_hand.append_array(_draw_pile.slice(idx_in_draw_pile))
	_draw_pile = _draw_pile.slice(0, idx_in_draw_pile)
	draw_pile_changed.emit(_draw_pile.size())
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
	
		if context.exhaust_required():
			_exhaust_pile.append(_hand.pop_at(idx))
			exhaust_changed.emit(_exhaust_pile.size())
		else:
			_discard_pile.append(_hand.pop_at(idx))
			discard_changed.emit(_discard_pile.size())
		card.queue_free()
	else:
		printerr("Invalid card played!")

	# Update card text
	for child in _hand_container.get_children():
		if child is Card:
			child.update_description(context)


## Discard the hand then draw a new hand, taking the new cards in
## priority from the draw pile, then shuffling the discard pile when
## the draw pile is empty
func draw_new_hand():
	for child in _hand_container.get_children():
		if child is Card:
			child.queue_free()

	_discard_pile.append_array(_hand)
	_hand.clear()

	if _draw_pile.size() <= HAND_SIZE:
		_hand.append_array(_draw_pile)
		_draw_pile.clear()

	if _draw_pile.size() == 0:
		_draw_pile.append_array(_discard_pile)

	fill_hand()

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

	_hand.append(_draw_pile.pop_back())
	draw_pile_changed.emit(_draw_pile.size())

	_show_hand()
	return true

