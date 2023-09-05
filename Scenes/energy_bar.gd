extends Control

class_name EnergyBar

# This signal is sent every time we exceed a step threshold
signal step_reached(step: int)

# This signal is sent when the bar is completely full (has reached max value)
signal filled 

# Time (in seconds) to fill the bar completely
@export var fill_time: float = 1
# Number of steps in the bar
@export var steps: Array[Color] = [Color.WHITE]

@export var step_count: int:
	set(value):
		step_count = min(steps.size(), value)
		
@onready var pb = $ProgressBar as ProgressBar
var sb = StyleBoxFlat.new()

var last_step:int= 0

func _ready():
	pb.add_theme_stylebox_override("fill", sb)
	sb.bg_color = steps[0]
	sb.set_corner_radius_all(3)

var shouldprint = false

var _range: int: 
	get:
		return pb.max_value - pb.min_value

# Every time it is called, increase the bar toward the maximum
# if it exceeds a step, send a signal
func _process(delta):
	var value_range = (pb.max_value - pb.min_value)
	var added_ratio = delta / fill_time
	var ratio_so_far = (pb.value - pb.min_value) / value_range
	var new_filled_ratio = ratio_so_far + added_ratio
	var current_step_reached = min(floori(new_filled_ratio * step_count), step_count)
	
	# We need to update everything before calling the signals, as these may in turn 
	# update these values
	var last_step_before_update = last_step
	last_step = current_step_reached

	# The framework takes care of overflow for us
	var current_filled_value = new_filled_ratio * value_range + pb.min_value 
	pb.set_value_no_signal(current_filled_value)
	
	# When crossing a new step, send the signal
	if current_step_reached != last_step_before_update: 
		step_reached.emit(current_step_reached)
		_update_color(current_step_reached)
	
	# When completely filled, send the signal
	if new_filled_ratio >= 1: 
		if last_step_before_update != step_count:
			filled.emit()
	

func reset_energy():
	set_energy_no_signal(0)
	
func deduct_energy(count: int): 
	var value_range = pb.max_value - pb.min_value
	var step_value = value_range / step_count
	var current_step = last_step
	set_energy_no_signal(pb.value - (count * step_value))
	if last_step != current_step:
		step_reached.emit(last_step)
		if last_step == step_count:
			filled.emit()
	
func set_energy_no_signal(energy: float): 
	var expected_value = max(pb.min_value, min(pb.max_value, energy))
	var current_filled_ratio = expected_value / (pb.max_value - pb.min_value)
	var current_step_reached = min(floori(current_filled_ratio * step_count), step_count)
	
	pb.set_value_no_signal(expected_value)
	last_step = current_step_reached
	_update_color(current_step_reached)

func force_to_step(step: int): 
	var current_step = min(floori(pb.ratio * step_count), step_count)
	var step_value = _range / step_count
	var fract = pb.value - (current_step * step_value)
	var new_value = (step * step_value) + fract
	pb.set_value_no_signal(new_value)
	last_step = current_step
	_update_color(current_step)

func _update_color(step: int):
	sb.bg_color = steps[min(step, steps.size() - 1)]
