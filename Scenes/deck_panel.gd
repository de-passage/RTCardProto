extends MarginContainer

signal deck_panel_closed
signal card_selected(card: CardResource)
@onready var _deck_container = $PanelContainer/DeckMarginContainer/ScrollContainer/Deck

var _card_scene = preload("res://Scenes/card.tscn")

func _ready():
	_display_deck()
	Global.deck_changed.connect(_display_deck)
	_display_deck()

func _display_deck():
	for child in _deck_container.get_children():
		child.queue_free()
	
	var deck = Global.get_current_deck()
	for card_resource in deck:
		var card: Card = _card_scene.instantiate()
		card.initialize(card_resource, Global.get_player())
		card.selected.connect(_on_card_selected.bind(card_resource))
		_deck_container.add_child(card)

func _on_close_button_pressed():
	deck_panel_closed.emit()

func _on_card_selected(card: CardResource): 
	card_selected.emit(card)
