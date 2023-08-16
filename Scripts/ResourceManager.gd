@tool
extends Node

class_name CGResourceManager


static func load_resources(path: String, process: Callable):	
	var files = DirAccess.get_files_at(path)
	for file_name in files:
		# Some files get .remap extensions once exported. However, 
		# trying to load a remap extension fails... 
		if '.tres.remap' in file_name:
			file_name = file_name.trim_suffix('.remap')
		var res = load("%s/%s" % [path, file_name])
		process.call(res)

const CARDS_PATH = "res://Cards"
const ENEMIES_PATH = "res://Characters/Enemies"

static func load_enemies():
	var enemies = []
	CGResourceManager.load_resources(ENEMIES_PATH, func(r): if r is EnemyResource: enemies.append(r))
	return enemies

static func load_cards():
	var cards = []
	CGResourceManager.load_resources(CARDS_PATH, func(r): if r is CardResource: cards.append(r))
	return cards
