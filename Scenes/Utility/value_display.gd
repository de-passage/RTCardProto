extends HBoxContainer

class_name ValueDisplay

@export var always_visible: bool = false
@export var value: int = 0
@export var icon_texture: Texture2D
@export var icon_material: Material

@onready var _label = $Label as Label
@onready var _icon: TextureRect = $Icon as TextureRect

func _ready():
	if icon_texture != null:
		_icon.texture = icon_texture
	if icon_material != null:
		_icon.material = icon_material
		
	_display()

func _display():
	_label = str(value)
	visible = value > 0

func set_value(v: int):
	value = v
	_display()
