extends VBoxContainer

@onready var _enemy_scene: Enemy = $"../Enemy"
@onready var _pause_button: Button = $PauseButton
@onready var _time_slider: Slider = $TimeControl/TimeSlider
@onready var _time_box: SpinBox = $TimeControl/TimeBox
@onready var _current_time: Label = $CurrentTime

@onready var _player_energy: EnergyBar = $"../UI/EnergyContainer/EnergyBar"
@onready var _monster_energy: EnergyBar = $"../Enemy/Control/EnergyBar"
@onready var _player_bar_label: Label = $PlayerBar
@onready var _monster_bar_label: Label = $MonsterBar

func _ready():
	_time_box.value = TimeManager.time_speed
	_time_slider.value = TimeManager.time_speed
	_set_button_text()
	TimeManager.time_changed.connect(_on_time_changed)
	

func _on_win_button_pressed():
	_enemy_scene._entity.current_hp = 0


func _on_button_pressed():
	TimeManager.toggle_pause()
	_set_button_text()
	
func _set_button_text():
	_pause_button.text = "Resume" if TimeManager.paused else "Pause"


func _on_time_slider_value_changed(value):
	_time_box.value = value
	TimeManager.time_speed = value


func _on_time_box_value_changed(value):
	_time_slider.value = value
	TimeManager.time_speed = value

func _on_time_changed(t: float):
	_current_time.text = "%.4f" % TimeManager._time_since_start;

func _process(delta):
	_player_bar_label.text = "%s / %s" % [ _player_energy.pb.value, _player_energy.pb.max_value ]
	_monster_bar_label.text = "%s / %s" % [ _monster_energy.pb.value, _monster_energy.pb.max_value ]
