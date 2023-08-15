extends CanvasLayer
class_name HandManager

signal card_selected(card: CardResource)

# Visual constant
const SEPARATION = 35

# Resource management
var shownCards: Array[Card] = []
var _card_scene: PackedScene = preload("res://Scenes/card.tscn")

# Game Logic
var draw_pile: Array[CardResource]
var discard_pile: Array[CardResource]
var hand: Array[CardResource]
var exhaust_pile: Array[CardResource]
var player: PlayableEntity

const HAND_SIZE = 4

@onready var _hand_container = $HandContainer

# Build a new hand
func _show_hand(): 
	for card_resource in hand:
		var card: Card = _card_scene.instantiate()
		card.initialize(card_resource, player)
		card.scale = Vector2(1.,1.)
		card.selected.connect(_emit_selected.bind(card))
		_hand_container.add_child(card)
		shownCards.append(card)

func _emit_selected(cardScene: Card):
	card_selected.emit(cardScene)

func initialize(deck: Array[CardResource], player_ref:PlayableEntity):
	draw_pile = deck.duplicate();
	fill_hand()
	player = player_ref

## Shuffle the draw pile then draw until the hand is full
## Redraw the hand afterwards 
func fill_hand(): 
	draw_pile.shuffle()
	var need_to_draw = HAND_SIZE - hand.size()
	var idx_in_draw_pile = draw_pile.size() - need_to_draw
	hand.append_array(draw_pile.slice(idx_in_draw_pile))
	draw_pile = draw_pile.slice(0, idx_in_draw_pile)
	_show_hand()
	
## Play the given card on the enemy. This should probably use 
## the local player variable directly.
func play(card: Card, player_: PlayableEntity, enemy: PlayableEntity):
	for effect in card.get_effects():
		effect.apply_effect(player_, enemy)

	var idx = hand.find(card._resource)
	if idx >= 0: 
		discard_pile.append(hand.pop_at(idx))
		card.queue_free()
	else:
		printerr("Invalid card played!")
	
	# Update card text
	for child in _hand_container.get_children():
		if child is Card:
			child.update_description(player_)
	

## Discard the hand then draw a new hand, taking the new cards in 
## priority from the draw pile, then shuffling the discard pile when \
## the draw pile is empty
func draw_new_hand():
	for child in _hand_container.get_children():
		if child is Card:
			child.queue_free()
	
	discard_pile.append_array(hand)
	hand.clear()
	
	if draw_pile.size() <= HAND_SIZE: 
		hand.append_array(draw_pile)
		draw_pile.clear()
	
	if draw_pile.size() == 0:
		draw_pile.append_array(discard_pile)
	
	fill_hand()
	
