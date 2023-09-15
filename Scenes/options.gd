extends Control

@onready var _time_speed_slider = $VBoxContainer/TimeSpeedBox/TimeSpeedSlider as Slider
@onready var _time_speed_value = $VBoxContainer/TimeSpeedBox/TimeSpeedValue as SpinBox

@onready var _fill_time_slider = $VBoxContainer/FillTimeBox/FillTimeSlider as Slider
@onready var _fill_time_value = $VBoxContainer/FillTimeBox/FillTimeValue as SpinBox

@onready var _time_demo_bar = $VBoxContainer/DemoBarContainer/DemoEnergyBar as EnergyBar
@onready var _time_demo_label = $VBoxContainer/DemoBarContainer/DemoEnergyLabel as Label

@onready var _window_mode = $VBoxContainer/WindowModeOptions as OptionButton

func _ready():
	_time_speed_slider.value = TimeManager.time_speed
	_time_speed_value.value = TimeManager.time_speed
	
	_fill_time_slider.value = GameInternalValues.get_fill_time()
	_fill_time_value.value = GameInternalValues.get_fill_time()
	
	_time_demo_bar.fill_time = GameInternalValues.get_fill_time()
	_time_demo_bar.filled.connect(_reset_energy_bar)
	GameInternalValues.fill_time_changed.connect(func(x): _time_demo_bar.fill_time = x)
	_time_demo_bar.step_reached.connect(func(x): _time_demo_label.text = str(x))
	
	match GameInternalValues.get_window_mode():
		DisplayServer.WINDOW_MODE_FULLSCREEN: _window_mode.select(0)
		_: _window_mode.select(1)

func _on_time_speed_value_value_changed(value):
	_time_speed_slider.value = value
	
	TimeManager.time_speed = value


func _on_time_speed_slider_value_changed(value):
	_time_speed_value.value = value

	TimeManager.time_speed = value


func _on_close_button_pressed():
	GameInternalValues.save()
	SceneManager.exit_scene()

func _reset_energy_bar(): 
	_time_demo_bar.reset_energy()


func _on_fill_time_slider_value_changed(value):
	_fill_time_value.value = value
	GameInternalValues.set_fill_time(value)


func _on_fill_time_value_value_changed(value):
	_fill_time_slider.value = value
	GameInternalValues.set_fill_time(value)


func _on_check_box_toggled(button_pressed):
	GameInternalValues.set_autopause(button_pressed)


func _on_window_mode_options_item_selected(index):
	if index == 0:
		GameInternalValues.set_window_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		GameInternalValues.set_window_mode(DisplayServer.WINDOW_MODE_WINDOWED)
