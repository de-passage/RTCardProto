extends MarginContainer
class_name DeckPanel

signal deck_panel_closed
signal card_selected(card: CardDeckInstance)
@onready var _deck_container = $PanelContainer/DeckMarginContainer/ScrollContainer/Deck

var _card_scene = preload("res://Scenes/card.tscn")

func _ready():
	Global.deck_changed.connect(_display_deck)
	_display_deck()

func _display_deck():
	for child in _deck_container.get_children():
		child.queue_free()
	
	for card_resource in Global.get_current_deck():
		var card: Card = _card_scene.instantiate()
		_deck_container.add_child(card)
		card.initialize(card_resource, Global.get_player())
		card.selected.connect(_on_card_selected)

func _on_close_button_pressed():
	deck_panel_closed.emit()

func _on_card_selected(card: CardDeckInstance): 
	card_selected.emit(card)
