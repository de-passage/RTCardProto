extends Node2D

@onready var player = Player.new(Global.current_health, Global.current_max_health)
var energy = 0
var deck: Array[CardResource]
@onready var manager: HandManager = $Hand

func _ready():
	player.current_hp = Global.current_health
	$UI/Health.connect_playable_entity(player)
	
	$Enemy.resource = Global.random_enemy()
	print("Loaded %s" % $Enemy.resource.name)
	
	$Enemy.entity.died.connect(_on_enemy_died)
	player.died.connect(_on_player_died)
	
	manager.initialize(Global.current_deck, player)

func _play_card(card: Card): 
	if card.cardCost <= energy: 
		$UI/EnergyContainer/EnergyBar.deduct_energy(card.cardCost)
		manager.play(card, player, $Enemy.entity)


func _on_energy_bar_step_reached(step):
	energy = step

func _on_player_died():
	Global.recapMessage = "You died!"
	Global.current_health = 0
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/recap_screen.tscn")

func _on_enemy_died():
	Global.recapMessage = "You won!"
	Global.current_health = player.current_hp
	Global.rewards = { "coins": $Enemy.coin_value }
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/recap_screen.tscn")


func _on_deck_refreshed():
	manager.draw_new_hand()


func _on_enemy_effects(effect):
	effect.call(player)
