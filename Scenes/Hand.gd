extends CanvasLayer
class_name HandManager

signal card_selected(card: CardResource)

const SEPARATION = 35

var shownCards: Array[Card] = []

func _offset_card(card: Card, offset: int): 
	card.position = $HandStart.position + \
		Vector2((card.get_width() + SEPARATION) * offset, 0)

func _draw_hand(player: PlayableEntity): 
	var offset_count = 0
	for card in hand:
		var cardScene = load("res://Scenes/card.tscn").instantiate()
		cardScene.resource = card
		cardScene.update(player)
		cardScene.scale = Vector2(1.,1.)
		cardScene.selected.connect(_emit_selected.bind(cardScene))
		_offset_card(cardScene, offset_count)
		add_child(cardScene)
		shownCards.append(cardScene)
		offset_count+=1

func _emit_selected(cardScene: Node2D):
	card_selected.emit(cardScene)

var draw_pile: Array[CardResource]
var discard_pile: Array[CardResource]
var hand: Array[CardResource]
var exhaust_pile: Array[CardResource]

const HAND_SIZE = 4

var player

func initialize(deck: Array[CardResource], player_ref:PlayableEntity):
	draw_pile = deck.duplicate();
	fill_hand()
	player = player_ref

func fill_hand(): 
	draw_pile.shuffle()
	var need_to_draw = HAND_SIZE - hand.size()
	var idx_in_draw_pile = draw_pile.size() - need_to_draw
	hand.append_array(draw_pile.slice(idx_in_draw_pile))
	draw_pile = draw_pile.slice(0, idx_in_draw_pile)
	_draw_hand(player)
	

func play(card: Card, player: PlayableEntity, enemy: PlayableEntity):
	for effect in card.effects:
		effect.apply_effect(player, enemy)

	var idx = hand.find(card.resource)
	if idx >= 0: 
		discard_pile.append(hand.pop_at(idx))
		card.queue_free()
	else:
		printerr("Invalid card played!")
	
	var offsetCount = 0
	for child in get_children(): 
		if child is Card and not child.is_queued_for_deletion():
			_offset_card(child, offsetCount)
			offsetCount += 1
	
func draw_new_hand():
	for child in get_children():
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
	
