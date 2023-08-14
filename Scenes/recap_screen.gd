extends Control

enum { CONTINUE, RESTART }

var whatNext
@onready var coin_button = $VBox/Rewards/Buttons/CoinButton

@onready var potion_button = $VBox/Rewards/Buttons/PotionButton

@onready var card_button = $VBox/Rewards/Buttons/CardButton

@onready var relic_button = $VBox/Rewards/Buttons/RelicButton

func _ready():
	var label = $VBox/Recap
	var next_button = $VBox/RestartButton
	
	if Global.rewards.get("coins", 0) > 0:
		coin_button.text = "%s Coins" % Global.rewards.get("coins")
		coin_button.visible = true
	else:
		coin_button.visible = false	
		
	if Global.rewards.get("potion") != null:
		potion_button.text = Global.rewards.get("potion")
		potion_button.visible = true
	else:
		potion_button.visible = false
		
	if Global.rewards.get("relic") != null:
		relic_button.text = Global.rewards.get("relic")
		relic_button.visible = true
	else:
		relic_button.visible = false

	if Global.rewards.get("card") != null:
		card_button.visible = true
	else:
		card_button.visible = false
		
	if Global.current_health == 0: 
		label.text = "Defeat..."
		next_button.text = "Try again!"
		whatNext = RESTART
		Global.reset_game_values()
	else:
		label.text = "Victory!"
		next_button.text = "Onward!"
		whatNext = CONTINUE

func _on_restart_button_pressed():
	Global.rewards = {}
	get_tree().change_scene_to_file("res://Scenes/path_selection.tscn")

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_coin_button_pressed():
	Global.current_money += Global.rewards.get("coins", 0)
	coin_button.visible = false

func _on_potion_button_pressed():
	pass # Replace with function body.

func _on_card_button_pressed():
	pass # Replace with function body.

func _on_relic_button_pressed():
	pass # Replace with function body.
