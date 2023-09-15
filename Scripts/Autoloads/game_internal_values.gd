extends Node

const RESOURCE_PATH: StringName = "user://values.tres"

signal fill_time_changed(new_value: float)
signal autopause_changed(new_value: bool)

var _resource: GameValueResource

func _ready():
	if not FileAccess.file_exists(RESOURCE_PATH):
		ResourceSaver.save(GameValueResource.new(), RESOURCE_PATH)
		
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

func autopause() -> bool:
	return _resource.autopause

func set_autopause(b: bool):
	_resource.autopause = b
	autopause_changed.emit(b)
