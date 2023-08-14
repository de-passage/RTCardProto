extends Node

var recapMessage: String = ""

var cards: Array = []
var enemies: Array = []

const CARDS_PATH = "res://Cards"
const ENEMIES_PATH = "res://Characters/Enemies"

func load_resources(path: String, validate: Callable):	
	var files = DirAccess.get_files_at(path)
	var result = []
	for file in files: 
		var res = load("%s/%s" % [path, file])
		if validate.call(res): 
			result.append(res)
	return result

func load_enemies():
	enemies = load_resources(ENEMIES_PATH, func(r): return r is EnemyResource)

func load_cards():
	cards = load_resources(CARDS_PATH, func(r): return r is CardResource)

func get_starter() -> StarterDeck :
	return preload("res://Characters/Starter/DefaultStarter.tres")

var current_deck: Array[CardResource] = get_starter().cards
var current_max_health: int = 50
var current_health: int = 50
var current_money: int = 50

var rewards: Dictionary = {}

func reset_game_values(): 
	current_max_health = 50
	current_health = 50
	current_deck = get_starter().cards
	current_money = 50
	Maze.generate_new_level()

func random_enemy() -> EnemyResource:
	if enemies.is_empty():
		load_enemies()
	var r = randi_range(0, enemies.size() - 1)
	print("Rolled %s" % r)
	return enemies[r]
