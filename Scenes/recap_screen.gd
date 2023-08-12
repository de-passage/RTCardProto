extends Control

func _ready():
	var target = $VBoxContainer/Recap
	if Global.recapMessage == "" or Global.recapMessage == null: 
		target.text = "The dungeon collapsed!"
	else:
		target.text = Global.recapMessage

func _on_restart_button_pressed():
	print("restart clicked")
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_main_menu_button_pressed():
	print("main menu clicked")
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
