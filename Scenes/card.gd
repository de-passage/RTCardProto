@tool
extends Node2D

signal selected

@export_multiline var cardDescription: String: 
	set(value): 
		$Values/Description.text = value

@export var cardName: String:
	set(value):
		$Values/Name.text = value

@export var cardCost: int:
	set(value): 
		cardCost = value
		$Values/Cost.text = str(value)


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed: 
		selected.emit()
