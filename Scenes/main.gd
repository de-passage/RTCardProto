extends Node2D

@onready var player = Player.new(Global.current_health, Global.current_max_health)
var energy = 0
var deck: Array[CardResource]

@onready var _manager = $Hand
@onready var _health_manager = $UI/Health
@onready var _energy_manager = $UI/EnergyContainer/EnergyBar
@onready var _enemy_scene = $Enemy
@onready var _discard_label = $DiscardPile/DiscardLabel
@onready var _deck = $Deck

@export var DRAW_COST = 1

func _ready():
	player.current_hp = Global.current_health
	_health_manager.connect_playable_entity(player)

	_enemy_scene.initialize(Global.current_enemy())
	_enemy_scene.died.connect(_on_enemy_died)

	player.died.connect(_on_player_died)

	_manager.initialize(Global.current_deck, player)

func _play_card(card: Card):
	if card.card_cost() <= energy:
		_energy_manager.deduct_energy(card.card_cost())
		_manager.play(card, player, _enemy_scene.get_entity())

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
		_manager.draw_one_card()
		_energy_manager.deduct_energy(DRAW_COST)


func _on_enemy_effects(effect):
	effect.call(player)


func _on_win_button_pressed():
	_enemy_scene._entity.current_hp = 0


func _on_hand_discard_changed(new_size):
	_discard_label.text = str(new_size)


func _on_hand_draw_pile_changed(new_size):
	_deck.change_card_count(new_size)
