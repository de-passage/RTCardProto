extends MarginContainer

signal please_exit

@onready var _health = $HUD/HealthLabel
@onready var _money = $HUD/CoinLabel
@onready var _deck_panel = $DeckPanelContainer

func _ready():
	Global.money_changed.connect(_display_money)
	Global.health_changed.connect(_display_health)
	_display_health()
	_display_money()
	
func _display_money():
	_money.text = "%s" % Global.current_money

func _display_health():
	_health.text = "%s/%s" % [Global.current_health, Global.current_max_health]

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_deck_button_pressed():
	_toggle_modal(true)
	
func _toggle_modal(val: bool):
	_deck_panel.visible = val


func _on_deck_panel_container_deck_panel_closed():
	_toggle_modal(false)
