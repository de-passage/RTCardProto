extends Node

var recapMessage: String = ""

var cards: Array[CardResource] = []

func load_cards():
	var files = DirAccess.get_files_at("res://Cards")
	for file in files: 
		var res = load("res://Cards/%s" % file)
		if res is CardResource: 
			cards.append(res)
			print("loaded %s" % res.cardName)

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
