extends MarginContainer

signal please_exit

@onready var _health = $HUD/HealthLabel
@onready var _money = $HUD/CoinLabel
@onready var _deck_panel = $DeckPanelContainer
@onready var _deck_container = $DeckPanelContainer/PanelContainer/DeckMarginContainer/ScrollContainer/Deck

var _modal_opened = false
var _card_scene = preload("res://Scenes/card.tscn")

func _ready():
	Global.money_changed.connect(_display_money)
	Global.health_changed.connect(_display_health)
	_display_health()
	_display_money()
	
	Global.deck_changed.connect(_display_deck)
	_display_deck()

func _display_money():
	_money.text = "%s" % Global.current_money

func _display_health():
	_health.text = "%s/%s" % [Global.current_health, Global.current_max_health]

func _display_deck():
	for child in _deck_container.get_children():
		child.queue_free()
	
	var deck = Global.get_current_deck()
	for card_resource in deck:
		var card: Card = _card_scene.instantiate()
		card.initialize(card_resource, Global.get_player())
		_deck_container.add_child(card)  	

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_close_button_pressed():
	_toggle_modal(false)

func _on_deck_button_pressed():
	_display_deck()
	_toggle_modal(true)
	
func _toggle_modal(val: bool):
	_modal_opened = val
	_deck_panel.visible = val
