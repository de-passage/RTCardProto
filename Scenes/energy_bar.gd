extends Control

# This signal is sent every time we exceed a step threshold
signal step_reached(step: int)

# This signal is sent when the bar is completely full (has reached max value)
signal filled 

# Time (in seconds) to fill the bar completely
@export var fill_time: int = 1
# Number of steps in the bar
@export var steps: Array[Color] =[Color.WHITE]

@export var step_count: int:
	set(value): 
		step_count = min(steps.size(), value)
		
@onready var pb = $ProgressBar
var sb = StyleBoxFlat.new()

var last_update_delta = 0
var last_step:int= 0

func _ready():
	pb.add_theme_stylebox_override("fill", sb)
	sb.bg_color = steps[0]
	sb.set_corner_radius_all(3)

# Every time it is called, increase the bar toward the maximum
# if it exceeds a step, send a signal
func _process(delta):
	var current_total_delta = last_update_delta + delta
	var current_filled_ratio = (current_total_delta / fill_time)
	var current_step_reached = min(floori(current_filled_ratio * step_count), step_count)
	
	# When crossing a new step, send the signal
	if current_step_reached != last_step: 
		step_reached.emit(current_step_reached)
		sb.bg_color = steps[min(current_step_reached, steps.size() - 1)]
	
	# When completely filled, send the signal
	if current_filled_ratio >= 1: 
		if last_step != step_count:
			filled.emit()
	
	# Doing it here because we need last_step info for both conditions before		
	last_step = current_step_reached

	# The framework takes care of overflow for us
	var current_filled_value = current_filled_ratio * (pb.max_value - pb.min_value) + pb.min_value 
	pb.set_value_no_signal(current_filled_value)
	
	last_update_delta = current_total_delta	
