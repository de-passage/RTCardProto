extends MarginContainer
class_name DeckBuilder

const DECK_FOLDER = "user://Decks/"

@onready var _all_cards = $ToolBar/HBoxContainer/AllCards/FlowContainer as HFlowContainer
@onready var _deck_view = $ToolBar/HBoxContainer/DeckView/FlowContainer as HFlowContainer
@onready var _deck_name = $ToolBar/ToolBox/RightSide/DeckName as Label

var _card_scene = preload("res://Scenes/card.tscn")

func _ready():
	if not DirAccess.dir_exists_absolute(DECK_FOLDER):
		DirAccess.make_dir_absolute(DECK_FOLDER)
	_show_default_deck()
	_show_all_cards()

func _show_default_deck():
	_show_deck(Global._get_starter().cards)
	_deck_name.text = Global.current_starter_name()

func _show_all_cards():
	var cards = Global.get_all_cards()
	for card in cards:
		var d = CardDeckInstance.new(card)
		if d.in_pool(Pools.UNUSED):
			continue
		var scene = _card_scene.instantiate() as Card
		
		_all_cards.add_child(scene)
		scene.initialize(CardDeckInstance.new(card), Player.new(1, 1, Context.new()))
		scene.selected.connect(func(_c): _add_to_deck(scene));

func _show_deck(deck: Array[CardResource]):
	for card in _deck_view.get_children(): 
		card.queue_free()
		
	for card in deck: 
		var scene = _card_scene.instantiate() as Card
		_deck_view.add_child(scene)
		scene.initialize(CardDeckInstance.new(card), Player.new(1, 1, Context.new()))
		scene.selected.connect(func(_c): _remove_from_deck(scene))

func _add_to_deck(card: Card):
	var dup: Card = card.duplicate()
	_deck_view.add_child(dup)
	dup.initialize(card.get_resource(), Player.new(1, 1, Context.new()))

func _remove_from_deck(card: Card):
	card.queue_free()

func _on_editor_panel_new_required():
	for child in _deck_view.get_children():
		child.queue_free()

	_show_default_deck()


func _on_editor_panel_load_required(path):
	var resource = load(path) as StarterDeck
	if resource == null: 
		printerr("This is not a starter deck")
		return
	
	_show_deck(resource.cards)
	_deck_name.text = DeckBuilder.deck_name_from_path(path)


func _on_editor_panel_save_required(path):
	var deck = StarterDeck.new()
	for child in _deck_view.get_children():
		if child is Card: 
			var c: CardDeckInstance = child.get_resource()
			var r: CardResource = c.get_resource()
			deck.cards.append(r)
	
	if ResourceSaver.save(deck, path) == OK: 
		_deck_name.text = DeckBuilder.deck_name_from_path(path)

static func deck_name_from_path(path) -> String:
	if path is String:
		var last_delim = max(0, path.rfind('/') + 1)
		var ext = path.find('.', last_delim)
		if ext >= 0: # if not found, -1 will indicate the eos
			ext = ext - last_delim
		return path.substr(last_delim, ext)
	return '<error>'


func _on_quit_button_pressed():
	SceneManager.exit_scene()
