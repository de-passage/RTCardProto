extends Sprite2D

@onready var _refresh_pivot = $RefreshPivot
@onready var _card_count_display = $Control/Label as Label
@onready var _wound_display = $Control/WoundDisplay as ValueDisplay

signal refreshed

func set_wound_count(nb: int): 
	_wound_display.set_value(nb)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if _refresh_pivot.is_visible_in_tree() \
		and event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
		refreshed.emit()

func change_card_count(i: int): 
	_card_count_display.text = str(i)
