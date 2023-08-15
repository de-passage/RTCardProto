extends HBoxContainer

signal please_exit

@onready var _health = $HealthLabel
@onready var _money = $CoinLabel

func _ready():
	Global.money_changed.connect(_display_money)
	Global.health_changed.connect(_display_health)
	_display_health()
	_display_money()

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _display_money():
	_money.text = "%s" % Global.current_money

func _display_health():
	_health.text = "%s/%s" % [Global.current_health, Global.current_max_health]
