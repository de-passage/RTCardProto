extends CanvasLayer
class_name HandManager

signal card_selected(card: CardDeckInstance)
signal card_discarded(card: CardDeckInstance)

signal draw_pile_changed(new_size: int)
signal discard_changed(new_size: int)
signal exhaust_changed(new_size: int)

# Resource management
var _card_scene: PackedScene = preload("res://Scenes/card.tscn")

var _game_logic: GameLogic

@onready var _hand_container = $HandContainer

# Creates the hand and so on
func initialize(deck: Array[CardDeckInstance], player_ref:PlayableEntity):
	_game_logic = GameLogic.new()
	_game_logic.discard_changed.connect(func(x): discard_changed.emit(x))
	_game_logic.draw_pile_changed.connect(func(x): draw_pile_changed.emit(x))
	_game_logic.exhaust_changed.connect(func(x): exhaust_changed.emit(x))
	_game_logic.hand_changed.connect(func(_x): _show_hand())
	_game_logic.card_played.connect(_on_card_played)
	_game_logic.card_discarded.connect(_on_card_played)
	_game_logic.initialize(player_ref, deck.duplicate())
	_show_hand()

# Build a new hand
func _show_hand():
	for child in _hand_container.get_children():
		if child is Card:
			child.queue_free()

	for card_resource in _game_logic.hand():
		var card: Card = _card_scene.instantiate()
		_hand_container.add_child(card)
		card.initialize(card_resource, _game_logic.player())
		card.scale = Vector2(1.,1.)
		card.selected.connect(_emit_selected)
		card.discarded.connect(_emit_discarded)

func _emit_selected(card: CardDeckInstance):
	card_selected.emit(card)

func _emit_discarded(card: CardDeckInstance):
	_game_logic.discard(card)

func play(card: CardDeckInstance, enemy: PlayableEntity):
	_game_logic.play(card, enemy)

func _on_card_played(card: CardGameInstance):
	# Update card text
	for child in _hand_container.get_children():
		if child is Card:
			child.update_description(Context.source_only(_game_logic.player()))
			if child.is_resource(card):
				child.queue_free()
				
func draw_one_card() -> bool:
	return _game_logic.draw_one_card()
