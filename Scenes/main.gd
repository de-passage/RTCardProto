extends Node2D

@onready var player = Player.new(Global.current_health, Global.current_max_health)
var energy = 0
var deck: Array[CardResource]
@onready var manager:  = $Hand

func _ready():
	player.current_hp = Global.current_health
	$UI/Health.connect_playable_entity(player)
	
	$Enemy.initialize(Global.current_enemy())
	$Enemy.died.connect(_on_enemy_died)
	
	player.died.connect(_on_player_died)
	
	manager.initialize(Global.current_deck, player)

func _play_card(card: Card): 
	if card.card_cost() <= energy: 
		$UI/EnergyContainer/EnergyBar.deduct_energy(card.card_cost())
		manager.play(card, player, $Enemy.get_entity())

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
	manager.draw_new_hand()


func _on_enemy_effects(effect):
	effect.call(player)


func _on_win_button_pressed():
	$Enemy._entity.current_hp = 0
