extends TextureRect

var _heal_value: int = 0
@onready var _rest_button = $VBoxContainer/RestButton
@onready var _card_removal = $MarginContainer

func _ready():
	var player = Global.get_player()
	_heal_value = player.max_hp / 4
	print(str(_heal_value))
	_rest_button.text = "Heal for %s" % _heal_value

func _on_rest_button_pressed():
	Global.current_health += _heal_value
	get_tree().change_scene_to_file("res://Scenes/path_selection.tscn")

func _on_remove_button_pressed():
	_card_removal.visible = true

func _on_deck_panel_card_removed(card: CardResource):
	Global.remove_from_deck(card)
	_card_removal.visible = false 
	get_tree().change_scene_to_file("res://Scenes/path_selection.tscn")

func _on_deck_panel_closed():
	_card_removal.visible = false
