extends Node2D

@onready var player: Player = Global.get_player()

@onready var _manager = $Hand as HandManager
@onready var _values_manager = $UI/Values
@onready var _energy_manager = $UI/EnergyContainer/EnergyBar as EnergyBar
@onready var _energy_label = $UI/EnergyContainer/EnergyCount as Label
@onready var _enemy_scene = $Enemy as Enemy
@onready var _discard_label = $DiscardPile/DiscardLabel
@onready var _deck = $Deck
@onready var _exhaust_pile = $ExhaustTexture
@onready var _exhaust_label = $ExhaustTexture/ExhaustLabel
@onready var _mana_label = $ManaLabel
@onready var _discard_wound_container = $DiscardPile/DiscardWoundDisplay as ValueDisplay

@onready var _energy_button = $UI/EnergyButton as Button

@export var DRAW_COST = 1

func _ready():
	TimeManager.reset()
	
	player.current_hp = Global.current_health
	_values_manager.connect_playable_entity(player)

	_energy_manager.fill_time = GameInternalValues.get_fill_time()
	GameInternalValues.fill_time_changed.connect(func(x): _energy_manager.fill_time = x)
	
	player.died.connect(_on_player_died)
	player.mana_changed.connect(_update_mana_label)
	player.energy_changed.connect(_update_energy)

	_manager.initialize(Global.get_current_deck(), player)

	_enemy_scene.initialize(Global.current_enemy(), player, _manager._game_logic)
	_enemy_scene.died.connect(_on_enemy_died)
	
	_show_wounds_in_discard()
	_show_wounds_in_draw()

func _play_card(card: CardDeckInstance):
	if card.energy_cost() <= player.energy \
		and card.playable() \
		and player.mana >= card.mana_cost():

		_energy_manager.deduct_energy(card.energy_cost())
		_manager.play(card, _enemy_scene.get_entity())
		player.mana -= card.mana_cost()
		_update_mana_label(player.mana)

func _on_energy_bar_step_reached(step):
	player.energy = step

func _on_player_died():
	_goto_recap_screen()

func _on_enemy_died(rewards: Dictionary):
	Global.rewards = rewards
	_goto_recap_screen()

func _goto_recap_screen():
	Global.update_player(player)
	SceneManager.swap_in_recap_screen()

func _on_deck_refreshed():
	_manager.draw_one_card() 

func _on_enemy_effects(effect):
	effect.call(player)

func _on_hand_discard_changed(new_size):
	_discard_label.text = str(new_size)
	_show_wounds_in_discard()
	
func _show_wounds_in_discard():
	var wounds = _manager.wounds_in_discard()
	_discard_wound_container.set_value(wounds)

func _on_hand_draw_pile_changed(new_size):
	_deck.change_card_count(new_size)
	_show_wounds_in_draw()

func _show_wounds_in_draw():
	_deck.set_wound_count(_manager.wounds_in_draw())

func _on_hand_exhaust_changed(new_size):
	_exhaust_pile.visible = new_size > 0
	_exhaust_label.text = str(new_size)

func _update_mana_label(mana: int):
	_mana_label.text = "Mana: %s" % mana

func _update_energy(energy: int): 
	_energy_manager.force_to_step(energy)
	_energy_label.text = str(energy)
	_energy_button.disabled = player.energy == player.max_energy

func _on_energy_button_pressed():
	if player.energy == player.max_energy: 
		return

	var time_to_next = _energy_manager.time_to_next_step()
	var time_to_enemy_next = _enemy_scene.time_to_next()
	
	# If the player gets energy first
	if time_to_next <= time_to_enemy_next: 
		TimeManager.fast_forward(time_to_next)
	# Otherwise allow the monster to play and resume filling its bar
	else:
		# Let the monster play
		TimeManager.fast_forward(time_to_enemy_next)
		# Pretend that the button was pressed again
		_on_energy_button_pressed()

func _physics_process(_delta):
	if Input.is_action_just_pressed("gain_energy"):
		_on_energy_button_pressed()
