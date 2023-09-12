extends Node

const RESOURCE_PATH: StringName = "user://values.tres"

signal fill_time_changed(new_value: float)

var _resource: GameValueResource

func _ready():
	var loaded = load(RESOURCE_PATH)
	if loaded != null and loaded is GameValueResource:
		_resource = loaded
		TimeManager.time_speed = _resource.time_speed
	else: 
		_resource = GameValueResource.new()
	TimeManager.time_speed_changed.connect(func(x): _resource.time_speed = x )

func save(): 
	ResourceSaver.save(_resource, RESOURCE_PATH)

func get_fill_time(): 
	return _resource.fill_time

func set_fill_time(v: float):
	_resource.fill_time = v
	fill_time_changed.emit(v)
