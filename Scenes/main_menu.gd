extends Control

func _ready():
	CGResourceManager.load_cards()

func _on_quit_button_pressed():
	get_tree().quit()


func _on_start_button_pressed():
	Global.reset_game_values()
	get_tree().change_scene_to_file("res://Scenes/path_selection.tscn")


func _on_option_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/option_screen.tscn")
