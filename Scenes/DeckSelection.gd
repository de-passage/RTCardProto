extends OptionButton

var _additional_decks: Array[Global.Deck] = []

func _ready():
	if not DirAccess.dir_exists_absolute(DeckBuilder.DECK_FOLDER):
		DirAccess.make_dir_absolute(DeckBuilder.DECK_FOLDER)
	
	_additional_decks.append(Global.Deck.new("Default", null))
		
	var idx: int = 1
	
	for file in DirAccess.get_files_at(DeckBuilder.DECK_FOLDER):
		var r = load(DeckBuilder.DECK_FOLDER + file)

		if r != null: 
			var deck_name = DeckBuilder.deck_name_from_path(file)
			_additional_decks.append(Global.Deck.new(deck_name, r))
			add_item(deck_name)
			
			if Global.current_starter_name() == deck_name:
				select(idx)
			idx += 1

func _on_deck_selection_item_selected(index):
	if index >= 0:
		Global.set_starter_deck(_additional_decks[self.selected])
