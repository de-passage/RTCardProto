extends Control

enum { CONTINUE, RESTART }

var whatNext

func _ready():
	var label = $VBoxContainer/Recap
	var next_button = $VBoxContainer/RestartButton
	
	if Global.current_health == 0: 
		label.text = "Defeat..."
		next_button.text = "Try again!"
		whatNext = RESTART
		Global.reset_game_values()
	else:
		label.text = "Victory!"
		next_button.text = "Onward!"
		whatNext = CONTINUE
		
func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/path_selection.tscn")

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
