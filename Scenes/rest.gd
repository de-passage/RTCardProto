extends TextureRect

var _heal_value: int = 0
@onready var _rest_button = $VBoxContainer/RestButton

func _ready():
	var player = Global.get_player()
	_heal_value = player.max_hp / 4
	print(str(_heal_value))
	_rest_button.text = "Heal for %s" % _heal_value

func _on_rest_button_pressed():
	Global.current_health += _heal_value
	get_tree().change_scene_to_file("res://Scenes/path_selection.tscn")

func _on_remove_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/path_selection.tscn")
