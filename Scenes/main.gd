extends Node2D
	
enum CardType { ATTACK, DEFENSE, HEAL, INC_STRENGTH, ATTACK_AND_DRAW }

var draw_pile: Array[CardType] = []
var discard_pile : Array[CardType] = []

var player = Player.new(11)
var energy = 0
var deck: Array[CardResource]
@onready var manager: HandManager = $Hand

func _ready():	
	$UI/Health.connect_playable_entity(player)
	
	$Enemy.entity.died.connect(_on_enemy_died)
	player.died.connect(_on_player_died)
	
	manager.initialize(Global.current_deck, player)

func _on_enemy_attacking():
	player.deal_damage(5)

func _play_card(card: Card): 
	if card.cardCost <= energy: 
		$UI/EnergyContainer/EnergyBar.deduct_energy(card.cardCost)
		manager.play(card, player, $Enemy.entity)

func _on_sample_attack_selected():
	_play_card($Hand/SampleAttack)

func _on_sample_defense_selected():
	_play_card($Hand/SampleDefense)

func _on_energy_bar_step_reached(step):
	energy = step

func _on_player_died():
	Global.recapMessage = "You died!"
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/recap_screen.tscn")

func _on_enemy_died():
	Global.recapMessage = "You won!"
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/recap_screen.tscn")


func _on_deck_refreshed():
	manager.draw_new_hand()
