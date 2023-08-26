extends Node

signal deck_changed
signal money_changed
signal health_changed

var recapMessage: String = ""

enum EnemyPool { NORMAL, ELITE, BOSS }
enum LevelPool { DEFAULT } # extend for multiple levels


var _cards # Array[CardResource] | null
var _enemies # Expect this to be an array of arrays of enemies. First layer is the level, second is the pool

var current_deck: Array[CardResource]:
	set(value):
		current_deck = value
		deck_changed.emit()
	get:
		if current_deck == null or current_deck.size() == 0: 
			return _get_starter().cards
		else:
			return current_deck
		
var current_max_health: int = 50:
	set(value):
		current_max_health = value
		health_changed.emit()

var _current_health	= current_max_health
var current_health: int = 50:
	set(value):
		_current_health = clampi(value, 0, current_max_health)
		health_changed.emit()
	get: return _current_health
		
var current_money: int = 50:
	set(value):
		current_money = value
		money_changed.emit()
		
var _current_enemy: EnemyResource
var current_level: LevelPool = LevelPool.DEFAULT

const REWARD_COINS = "coins"
const REWARD_CARD = "card"
const REWARD_POTION = "potion"
const REWARD_RELIC = "relic"
var rewards: Dictionary = {}
var _possible_card_pool: Array[CardResource] = []

func get_player() -> Player: 
	return Player.new(current_health, current_max_health)

func update_player(player: Player):
	current_health = player.current_hp

func reset_game_values(): 
	current_max_health = 50
	current_health = 50
	current_deck = _get_starter().cards
	deck_changed.emit()
	current_money = 50
	Maze.generate_new_level()

func _random_enemy(level: LevelPool, pool: EnemyPool) -> EnemyResource:
	_load_enemies()
		
	var selected_pool = _enemies[level][pool]
	var r = randi_range(0, selected_pool.size() - 1)
	return selected_pool[r]

func current_enemy() -> EnemyResource: 
	if _current_enemy == null: 
		setup_random_enemy(LevelPool.DEFAULT, EnemyPool.NORMAL)
	return _current_enemy

func setup_random_enemy(level: LevelPool, pool: EnemyPool):
	_current_enemy = _random_enemy(level, pool)

func get_card_sample(sample_size: int = 3): 
	_load_card_pool()
	var max_reward = _possible_card_pool.size()
	_possible_card_pool.shuffle()
	return _possible_card_pool.slice(0, clamp(sample_size,  0, max_reward))
	
func _load_card_pool():
	if _possible_card_pool.size() == 0:
		_load_cards()
		for card in _cards:
			var is_in_pool: bool = true
			for label in card.pools:
				if label == &'Starter' or label == &'Curses':
					is_in_pool = false
					break
			if is_in_pool:
				_possible_card_pool.append(card)

func get_current_deck() -> Array[CardResource]: 
	if current_deck == null or current_deck.size() == 0: 
		current_deck = _get_starter().cards
	return current_deck

func remove_from_deck(card: CardResource):
	var idx = current_deck.find(card)
	if idx >= 0: 
		current_deck.remove_at(idx)
		deck_changed.emit()

func add_to_current_deck(card: CardResource):
	current_deck.append(card)

func _load_enemies():
	if _enemies != null: return
	
	var resources = CGResourceManager.load_enemies()
	_enemies = []
	for level in range(Global.LevelPool.size()):
		var level_array = []
		_enemies.append(level_array)
		for pool in range(Global.EnemyPool.size()):
			level_array.append([])
	for r in resources: 
		_enemies[r.level][r.type].append(r)

func _load_cards():
	if _cards == null:
		_cards = CGResourceManager.load_cards() as Array[CardResource]

func _get_starter() -> StarterDeck :
	return preload("res://Characters/Starter/DefaultStarter.tres")
