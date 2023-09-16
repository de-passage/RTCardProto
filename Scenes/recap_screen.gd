extends Control

@onready var _coin_button = $VBox/Rewards/Buttons/CoinButton
@onready var _potion_button = $VBox/Rewards/Buttons/PotionButton
@onready var _card_button = $VBox/Rewards/Buttons/CardButton
@onready var _relic_button = $VBox/Rewards/Buttons/RelicButton
@onready var _card_container = $CardSelection/CenterContainer/PanelContainer/MarginContainer/CenterContainer/VBoxContainer/HBoxContainer
@onready var _label = $VBox/Recap
@onready var _next_button = $VBox/RestartButton
@onready var _card_selection_panel = $CardSelection

var _card_scene = preload("res://Scenes/card.tscn")

var _player_entity = PlayableEntity.new(Global.current_max_health)

func _ready():
	var t = Timer.new()
	t.one_shot = true
	t.timeout.connect(func(): _next_button.disabled = false)
	add_child(t)
	t.start(1)
	if Global.rewards.get(Global.REWARD_COINS, 0) > 0:
		_coin_button.text = "%s Coins" % Global.rewards.get(Global.REWARD_COINS)
		_coin_button.visible = true
	else:
		_coin_button.visible = false	
		
	if Global.rewards.get(Global.REWARD_POTION) != null:
		_potion_button.text = Global.rewards.get(Global.REWARD_POTION)
		_potion_button.visible = true
	else:
		_potion_button.visible = false
		
	if Global.rewards.get(Global.REWARD_RELIC) != null:
		_relic_button.text = Global.rewards.get(Global.REWARD_RELIC)
		_relic_button.visible = true
	else:
		_relic_button.visible = false

	if Global.rewards.get(Global.REWARD_CARD) != null:
		_generate_rewards()
		_card_button.visible = true
	else:
		_card_button.visible = false
		
	if Global.current_health == 0: 
		_label.text = "Defeat..."
		_next_button.text = "Try again!"
		Global.reset_game_values()
	else:
		_label.text = "Victory!"
		_next_button.text = "Onward!"

func _on_restart_button_pressed():
	Global.rewards = {}
	SceneManager.exit_scene()

func _on_main_menu_button_pressed():
	SceneManager.exit_to_main_menu()

func _on_coin_button_pressed():
	Global.current_money += Global.rewards.get("coins", 0)
	_coin_button.visible = false

func _on_potion_button_pressed():
	pass # Replace with function body.

func _on_card_button_pressed():
	_card_selection_panel.visible = true

func _on_relic_button_pressed():
	pass # Replace with function body.

func _generate_rewards(): 
	for card_resource in Global.get_card_sample():
		var card: Card = _card_scene.instantiate()
		_card_container.add_child(card)
		card.initialize(card_resource, _player_entity)
		card.selected.connect(_on_card_selected)

func _on_card_selected(card: CardDeckInstance):
	Global.add_to_current_deck(card)
	_card_button.visible = false
	_card_selection_panel.visible = false

func _on_close_button_pressed():
	_card_selection_panel.visible = false
