extends Node2D

@export var max_hp: int:
	set(value):
		entity.max_hp = value
	get:
		return entity.max_hp
		
@export var height: int = 32
@export var width: int = 32
		
var entity = PlayableEntity.new(50)

func _ready():
	var t = $Sprite.texture
	var w = float(width) / t.get_width()
	var h = float(height) / t.get_height()
	$Sprite.apply_scale(Vector2(w, h))
