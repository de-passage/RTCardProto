extends Node

## Sent whenever we cross a virtual second threshold 
signal stepped()

## Sent on change of actual time speed
signal time_speed_changed(speed: float)

## Send on time change (with delta)
signal time_changed(delta: float)

## Desired time speed. 1 means the time flows at a normal rate
## 0 means it is stopped. The actual speed may be different if the game
## is paused
@export var time_speed: float = 1.0:
	set(value):
		time_speed = max(0, value)
		_actual_time_speed = time_speed
		
## Desired time speed when slowed down. Keep 0 < this < 1 
@export var slowed_down: float = 0.3

## How much does time actually move
@onready var _actual_time_speed: float = time_speed:
	set(value):
		_actual_time_speed = value
		time_speed_changed.emit(_actual_time_speed)

var _time_since_start: float = 0.0:
	set(value): 
		var last = _time_since_start
		_time_since_start = value
	
		time_changed.emit(value - last)		
		if floorf(last) < floorf(_time_since_start):
			stepped.emit() 

func _process(delta):
	var elapsed = delta * _actual_time_speed
	_time_since_start += elapsed
	
## Sets internal conter to 0
func reset(): 
	_time_since_start = 0
	
## Pauses time 
func pause():
	_actual_time_speed = 0

## Run time at the desired speed
func run(): 
	_actual_time_speed = time_speed

## Step to the next whole second. For example if 
## about 3.2341 seconds have elapsed, calling this 
## function will set the time to 4.0 seconds
func step(): 
	var next: float = floorf(_time_since_start + 1.)
	_time_since_start = next
