extends Sprite2D

signal refreshed

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if $RefreshPivot.is_visible_in_tree() \
		and event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
		refreshed.emit()
