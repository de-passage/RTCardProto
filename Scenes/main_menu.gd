extends Control

	
func _on_quit_button_pressed():
	get_tree().quit()


func _on_start_button_pressed():
	Global.reset_game_values() 
	SceneManager.go_to_path_selection()


func _on_option_button_pressed():
	SceneManager.go_to_options()


func _on_deck_editor_pressed():
	SceneManager.go_to_deck_editor()


func _on_arena_button_pressed():
	SceneManager.go_to_arena()
