extends Control

class_name EnergyBar

# To avoid really small numbers being rounded by the progress bar
const PROGRESS_BAR_VALUE_MULTIPLIER = 1000

# This signal is sent every time we exceed a step threshold
signal step_reached(step: int)

# This signal is sent when the bar is completely full (has reached max value)
signal filled 

# Time (in seconds) to fill a single step
@export var fill_time: float = 1
# Number of steps in the bar
@export var steps: Array[Color] = [Color.WHITE]

@export var step_count: int:
	set(value):
		step_count = min(steps.size(), value)
		if _pb != null: 
			_pb.max_value = step_count * 1000
		
@onready var _pb = $ProgressBar as ProgressBar
var _sb = StyleBoxFlat.new()

func _ready():
	_pb.add_theme_stylebox_override("fill", _sb)
	_sb.bg_color = steps[0]
	_sb.set_corner_radius_all(3)
	
	_pb.min_value = 0.0
	_pb.max_value = step_count * 1000;
	_pb.value = 0.0
	_pb.rounded = false
	
	TimeManager.time_changed.connect(_on_time_change)

var shouldprint = false

func _current_step() -> int: 
	return floori(_get_value())
	
func time_to_next_step() -> float:
	var already_filled = (_get_value() - _current_step()) * fill_time;
	return fill_time - already_filled

func _get_value():
	return _pb.value / PROGRESS_BAR_VALUE_MULTIPLIER
	
func _set_value(value: float):
	_pb.set_value_no_signal(value * PROGRESS_BAR_VALUE_MULTIPLIER)

func _add_to_value(v: float):
	_pb.set_value_no_signal(_pb.value + v * PROGRESS_BAR_VALUE_MULTIPLIER)

func _max_value(): 
	return _pb.max_value / PROGRESS_BAR_VALUE_MULTIPLIER

# Every time it is called, increase the bar toward the maximum
# if it exceeds a step, send a signal
func _on_time_change(delta):
	
	# We need to update everything before calling the signals, as these may in turn 
	# update these values
	var last_step_before_update = _current_step()
	var diff = delta / fill_time
	_add_to_value(diff)
	var current_step = _current_step()
	
	# When crossing a new step, send the signal
	if current_step != last_step_before_update: 
		step_reached.emit(current_step)
		_update_color()
	
	# When completely filled, send the signal
	if _get_value() >= _max_value(): 
		if last_step_before_update != step_count:
			filled.emit()
	

func reset_energy():
	set_energy_no_signal(0)
	
func deduct_energy(count: int): 
	var last_step = _current_step()
	_set_value(_get_value() - count )
	var new_step = _current_step()
	if last_step != new_step:
		step_reached.emit(new_step)
		if last_step == step_count:
			filled.emit()
	
func set_energy_no_signal(energy: float): 
	_set_value(energy)
	_update_color()

func force_to_step(step: int): 
	_set_value(float(step))
	_update_color()

func _update_color():
	var step = _current_step()
	if steps.size() > step:
		_sb.bg_color = steps[step]
