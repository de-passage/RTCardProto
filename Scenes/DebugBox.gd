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
	TimeManager.time_paused.connect(func (_x): _set_button_text())

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

func _on_time_changed(_t: float):
	_current_time.text = "%.4f" % TimeManager._time_since_start;

func _process(_delta):
	_player_bar_label.text = "Player energy %.2f / %.2f (fill time: %.2f)" % [ _player_energy._get_value(), _player_energy._max_value(), _player_energy.fill_time ]
	_monster_bar_label.text = "Monster energy %.2f / %.2f (fill time: %.2f)" % [ _monster_energy._get_value(), _monster_energy._max_value(), _monster_energy.fill_time ]

func _physics_process(_delta):
	if Input.is_action_just_pressed("pause_game"):
		TimeManager.toggle_pause()
	


func _on_auto_pause_toggled(button_pressed):
	GameInternalValues.set_autopause(button_pressed)
