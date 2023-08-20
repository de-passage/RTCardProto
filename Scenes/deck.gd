extends Sprite2D

@onready var _refresh_pivot = $RefreshPivot
@onready var _card_count_display = $Control/Label as Label

signal refreshed

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if _refresh_pivot.is_visible_in_tree() \
		and event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
		refreshed.emit()

func change_card_count(i: int): 
	_card_count_display.text = str(i)
