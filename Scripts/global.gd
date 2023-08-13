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
