extends Sprite2D

signal clicked

func _input(event):
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed: 
		clicked.emit() 
