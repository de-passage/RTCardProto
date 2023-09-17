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

static func load_enemies() -> Array[EnemyResource]:
	var enemies: Array[EnemyResource] = []
	CGResourceManager.load_resources(ENEMIES_PATH, func(r): if r is EnemyResource: enemies.append(r))
	return enemies

static func load_cards() -> Array[CardResource]:
	var card_array: Array[CardResource] = []
	CGResourceManager.load_resources(CARDS_PATH, func(r): 
		if r is CardResource: card_array.append(r))
	return card_array

static var cards: Array[CardResource]:
	get:
		if cards == null or cards.size() == 0:
			cards = load_cards()
		return cards
	
static var effects: Array[GDScript]:
	get: 
		if effects == null or effects.size() == 0:
			effects = _load_effects()
		return effects

static func _load_effects() -> Array[GDScript]:
	var effs: Array[GDScript] = []
	CGResourceManager.load_resources("res://Scripts/Effects", func(r): if r is GDScript: effs.append(r))
	return effs
