extends Control

@onready var _deck_selection = $TextureRect/AdditionalMargin/AdditionalButtons/VBoxContainer/DeckSelection as OptionButton


var _additional_decks: Array[Global.Deck] = []

func _ready():
	_additional_decks.append(Global.Deck.new("Default", null))
	
	var idx: int = 1
	
	for file in DirAccess.get_files_at(DeckBuilder.DECK_FOLDER):
		var r = load(DeckBuilder.DECK_FOLDER + file)

		if r != null: 
			var name = DeckBuilder.deck_name_from_path(file)
			_additional_decks.append(Global.Deck.new(name, r))
			_deck_selection.add_item(name)
			
			if Global.current_starter_name() == name:
				_deck_selection.select(idx)
			idx += 1
	
func _on_quit_button_pressed():
	get_tree().quit()


func _on_start_button_pressed():
	Global.reset_game_values() 
	SceneManager.go_to_path_selection()


func _on_option_button_pressed():
	SceneManager.go_to_options()


func _on_deck_editor_pressed():
	SceneManager.go_to_deck_editor()


func _on_deck_selection_item_selected(index):
	if index >= 0:
		Global.set_starter_deck(_additional_decks[_deck_selection.selected])
