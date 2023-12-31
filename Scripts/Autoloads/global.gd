extends Node

signal deck_changed
signal money_changed
signal health_changed

var recapMessage: String = ""

enum EnemyPool { NORMAL, ELITE, BOSS }
enum LevelPool { DEFAULT } # extend for multiple levels

class Deck:
	var name: String
	var resource: StarterDeck
	func _init(n: String, r: StarterDeck):
		name = n
		resource = r
		

var _cards # Array[CardResource] | null
var _enemies # Expect this to be an array of arrays of enemies. First layer is the level, second is the pool

var _current_deck: Array[CardDeckInstance] = []
		
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
		money_changed.emit(current_money)
		
var _current_enemy: EnemyResource
var current_level: LevelPool = LevelPool.DEFAULT

const REWARD_COINS = "coins"
const REWARD_CARD = "card"
const REWARD_POTION = "potion"
const REWARD_RELIC = "relic"
var rewards: Dictionary = {}
var _possible_card_pool: Array[CardDeckInstance] = []
var _default_context: Context = Context.new()
var _starter_deck: Deck = Deck.new("Default", null)

func set_starter_deck(deck: Deck):
	_current_deck = []
	_starter_deck = deck

func current_starter_name() -> String:
	if _starter_deck == null: 
		return ""
	return _starter_deck.name

func get_player() -> Player: 
	return Player.new(current_health, current_max_health, _default_context)

func update_player(player: Player):
	current_health = player.current_hp

func reset_game_values(): 
	current_max_health = 50
	current_health = 50
	_current_deck = []
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

func set_current_enemy(r: EnemyResource):
	_current_enemy = r

func get_card_sample(sample_size: int = 3) -> Array[CardDeckInstance]: 
	_load_card_pool()
	var max_reward = _possible_card_pool.size()
	_possible_card_pool.shuffle()
	return _possible_card_pool.slice(0, clamp(sample_size,  0, max_reward))
	
func _load_card_pool():
	if _possible_card_pool.size() == 0:
		for card in get_all_cards():
			var is_in_pool: bool = true
			for label in card.pools:
				if label == &'Starter' or label == &'Curses' \
					or label == &'Unused':
					is_in_pool = false
					break
			if is_in_pool:
				_possible_card_pool.append(CardDeckInstance.new(card))

func get_current_deck() -> Array[CardDeckInstance]:
	if _current_deck == null or _current_deck.size() == 0: 
		_current_deck = []
		for card_resource in _get_starter().cards:
			_current_deck.append(CardDeckInstance.new(card_resource))
	return _current_deck

func reset_current_deck():
	_current_deck.clear()

func remove_from_deck(card: CardDeckInstance):
	var idx = _current_deck.find(card)
	if idx >= 0: 
		_current_deck.remove_at(idx)
		deck_changed.emit()

func add_to_current_deck(card: CardDeckInstance):
	_current_deck.append(card)
	deck_changed.emit()

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
	if _starter_deck != null and _starter_deck.resource != null:
		return _starter_deck.resource
	return preload("res://Characters/Starter/DefaultStarter.tres")

func get_all_cards() -> Array[CardResource]: 
	_load_cards()
	return _cards
