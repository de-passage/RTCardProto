extends Node2D

@onready var player: Player = Global.get_player()
var energy = 0

@onready var _manager = $Hand as HandManager
@onready var _health_manager = $UI/Health
@onready var _energy_manager = $UI/EnergyContainer/EnergyBar
@onready var _enemy_scene = $Enemy
@onready var _discard_label = $DiscardPile/DiscardLabel
@onready var _deck = $Deck
@onready var _exhaust_pile = $ExhaustTexture
@onready var _exhaust_label = $ExhaustTexture/ExhaustLabel
@onready var _mana_label = $ManaLabel

@export var DRAW_COST = 1

func _ready():
	player.current_hp = Global.current_health
	_health_manager.connect_playable_entity(player)

	player.died.connect(_on_player_died)
	player.mana_changed.connect(_update_mana_label)

	_manager.initialize(Global.get_current_deck(), player)

	_enemy_scene.initialize(Global.current_enemy(), player, _manager._game_logic)
	_enemy_scene.died.connect(_on_enemy_died)

func _play_card(card: CardDeckInstance):
	if card.energy_cost() <= energy \
		and card.playable() \
		and player.mana >= card.mana_cost():
		if card is CardGameInstance: 
			print("This is expected")
		_energy_manager.deduct_energy(card.energy_cost())
		_manager.play(card, _enemy_scene.get_entity())
		player.mana -= card.mana_cost()
		_update_mana_label(player.mana)

func _on_energy_bar_step_reached(step):
	energy = step

func _on_player_died():
	Global.recapMessage = "You died!"
	_goto_recap_screen()

func _on_enemy_died(rewards: Dictionary):
	Global.recapMessage = "You won!"
	Global.rewards = rewards
	_goto_recap_screen()

func _goto_recap_screen():
	Global.update_player(player)
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/recap_screen.tscn")

func _on_deck_refreshed():
	if energy >= DRAW_COST:
		if _manager.draw_one_card():
			_energy_manager.deduct_energy(DRAW_COST)


func _on_enemy_effects(effect):
	effect.call(player)


func _on_win_button_pressed():
	_enemy_scene._entity.current_hp = 0


func _on_hand_discard_changed(new_size):
	_discard_label.text = str(new_size)


func _on_hand_draw_pile_changed(new_size):
	_deck.change_card_count(new_size)


func _on_hand_exhaust_changed(new_size):
	_exhaust_pile.visible = new_size > 0
	_exhaust_label.text = str(new_size)

func _update_mana_label(mana: int):
	_mana_label.text = "Mana: %s" % mana
