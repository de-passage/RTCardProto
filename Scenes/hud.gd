extends MarginContainer

signal please_exit

@onready var _money = $HUD/MoneyDisplay as ValueDisplay
@onready var _deck_panel = $DeckPanelContainer

func _ready():
	Global.money_changed.connect(_money.set_value)
	
func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_deck_button_pressed():
	_toggle_modal(true)
	
func _toggle_modal(val: bool):
	if _deck_panel is InstancePlaceholder:
		_deck_panel = _deck_panel.create_instance(true) as DeckPanel
		_deck_panel.deck_panel_closed.connect(_on_deck_panel_container_deck_panel_closed)
	_deck_panel.visible = val

func _on_deck_panel_container_deck_panel_closed():
	_toggle_modal(false)
