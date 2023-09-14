extends Node

## Sent whenever we cross a virtual second threshold 
signal stepped()

## Sent on change of actual time speed
signal time_speed_changed(speed: float)

## Send on time change (with delta)
signal time_changed(delta: float)

## Sent on pause
signal time_paused(p: bool)

## For some reason the math doesn't work with 0, look into it
## The result is that the energy bar doesn't fill correctly if the 
## default value is 0. There probably are more pb with this
const START_VALUE: float = 0.000001

## Desired time speed. 1 means the time flows at a normal rate
## 0 means it is stopped. The actual speed may be different if the game
## is paused
@export var time_speed: float = .001:
	set(value):
		time_speed = max(0, value)
		if not paused: 
			_actual_time_speed = time_speed
		
## Desired time speed when slowed down. Keep 0 < this < 1 
@export var slowed_down: float = 0.3

## How much does time actually move
@onready var _actual_time_speed: float = time_speed:
	set(value):
		_actual_time_speed = value
		time_speed_changed.emit(_actual_time_speed)

var _time_since_start: float = START_VALUE:
	set(value): 
		var last = _time_since_start
		_time_since_start = value
	
		var change = value - last
		if change > 0:
			time_changed.emit(change)

		if floorf(last) < floorf(_time_since_start):
			stepped.emit() 

var paused: bool = false:
	set(value):
		paused = value
		_actual_time_speed = time_speed if not paused else 0.0
		time_paused.emit(paused)

func _physics_process(delta):
	var elapsed = delta * _actual_time_speed
	_time_since_start += elapsed
	
## Sets internal conter to 0
func reset(): 
	_time_since_start = START_VALUE

## Step to the next whole second. For example if 
## about 3.2341 seconds have elapsed, calling this 
## function will set the time to 4.0 seconds
func step(): 
	var next: float = floorf(_time_since_start + 1.)
	_time_since_start = next

func toggle_pause():
	paused = not paused

## Fast forward by the number given as input (in seconds)
func fast_forward(v: float):
	_time_since_start += v
