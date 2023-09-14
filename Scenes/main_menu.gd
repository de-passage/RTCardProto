extends Control

func _ready():
	CGResourceManager.load_cards()

func _on_quit_button_pressed():
	get_tree().quit()


func _on_start_button_pressed():
	Global.reset_game_values()
	SceneManager.go_to_path_selection()


func _on_option_button_pressed():
	SceneManager.go_to_options()
