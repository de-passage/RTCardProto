extends Node

var recapMessage: String = ""

var cards: Array[CardResource] = []
var enemies = [] # Expect this to be an array of arrays of enemies. First layer is the level, second is the pool
enum EnemyPool { NORMAL, ELITE, BOSS }
enum LevelPool { DEFAULT } # extend form multiple levels

const CARDS_PATH = "res://Cards"
const ENEMIES_PATH = "res://Characters/Enemies"

func load_resources(path: String, process: Callable):	
	var files = DirAccess.get_files_at(path)
	for file in files: 
		var res = load("%s/%s" % [path, file])
		process.call(res)

func load_enemies():
	enemies = []
	for level in range(LevelPool.size()):
		var level_array = []
		enemies.append(level_array)
		for pool in range(EnemyPool.size()):
			level_array.append([])
	load_resources(ENEMIES_PATH, func(r): if r is EnemyResource: enemies[r.level][r.type].append(r))
	

func load_cards():
	load_resources(CARDS_PATH, func(r): if r is CardResource: cards.append(r))

func get_starter() -> StarterDeck :
	return preload("res://Characters/Starter/DefaultStarter.tres")

var current_deck: Array[CardResource] = get_starter().cards
var current_max_health: int = 50
var current_health: int = 50
var current_money: int = 50
var _current_enemy: EnemyResource
var current_level: LevelPool = LevelPool.DEFAULT

const REWARD_COINS = "coins"
const REWARD_CARD = "card"
const REWARD_POTION = "potion"
const REWARD_RELIC = "relic"
var rewards: Dictionary = {}

func reset_game_values(): 
	current_max_health = 50
	current_health = 50
	current_deck = get_starter().cards
	current_money = 50
	Maze.generate_new_level()

func _random_enemy(level: LevelPool, pool: EnemyPool) -> EnemyResource:
	if enemies.is_empty():
		load_enemies()
		
	var selected_pool = enemies[level][pool]
	var r = randi_range(0, selected_pool.size() - 1)
	return selected_pool[r]

func current_enemy() -> EnemyResource: 
	if _current_enemy == null: 
		setup_random_enemy(LevelPool.DEFAULT, EnemyPool.NORMAL)
	return _current_enemy

func setup_random_enemy(level: LevelPool, pool: EnemyPool):
	_current_enemy = _random_enemy(level, pool)
