extends Control

@onready var _time_speed_slider = $VBoxContainer/HBoxContainer/TimeSpeedSlider as Slider
@onready var _time_speed_value = $VBoxContainer/HBoxContainer/TimeSpeedValue as SpinBox

@onready var _time_demo_bar = $VBoxContainer/DemoEnergyBar as EnergyBar


func _ready():
	_time_speed_slider.value = TimeManager.time_speed
	_time_speed_value.value = TimeManager.time_speed
	
	_time_demo_bar.filled.connect(_reset_energy_bar)

func _on_time_speed_value_value_changed(value):
	_time_speed_slider.value = value
	
	TimeManager.time_speed = value


func _on_time_speed_slider_value_changed(value):
	_time_speed_value.value = value

	TimeManager.time_speed = value


func _on_close_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _reset_energy_bar(): 
	_time_demo_bar.reset_energy()
