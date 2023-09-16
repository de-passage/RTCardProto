extends TextureRect

var _heal_value: int = 0
@onready var _rest_button = $VBoxContainer/RestButton
@onready var _card_removal = $MarginContainer

func _ready():
	_rest_button.disabled = _worst_wound() == null
	var player = Global.get_player()
	_heal_value = player.max_hp / 4
	print(str(_heal_value))
	
func _on_rest_button_pressed():
	var worst_wound = _worst_wound()
	if worst_wound != null: 
		Global.remove_from_deck(worst_wound)	
	SceneManager.exit_scene()

func _on_remove_button_pressed():
	_card_removal.visible = true

func _on_deck_panel_card_removed(card: CardDeckInstance):
	Global.remove_from_deck(card)
	_card_removal.visible = false 
	SceneManager.exit_scene()

func _on_deck_panel_closed():
	_card_removal.visible = false


func _worst_wound():
	var worst = null
	var max: int = 0
	for card in Global.get_current_deck(): 
		for status in card.statuses():
			if status is Wound: 
				var v = status.get_value()
				if v > max: 
					max = v
					worst = card
	return worst


func _on_ignore_button_pressed():
	SceneManager.exit_scene()
