@tool
extends HBoxContainer

class_name ValueDisplay

@export var always_visible: bool = false:
	set(v):
		always_visible = v
		if always_visible: 
			visible = true

@export var value: int = 0

@export var icon_texture: Texture2D:
	set(text):
		icon_texture = text
		if _icon != null: 
			_icon.texture = icon_texture
			
@export var icon_material: Material:
	set(mat):
		icon_material = mat
		if _icon != null:
			_icon.material = icon_material

@onready var _label = $Label as Label
@onready var _icon: TextureRect = $Icon as TextureRect

func _ready():
	if icon_texture != null:
		_icon.texture = icon_texture
	if icon_material != null:
		_icon.set_material(icon_material)
		
	_display()

func _display():
	_set_text()
	visible = always_visible or value > 0

func set_value(v: int):
	value = v
	_display()

func _set_text():
	_label.text = str(value)
