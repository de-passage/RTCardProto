extends Sprite2D

signal refreshed

func _ready():
	$RefreshPivot.hide()
	
func _on_energy_bar_filled():
	$RefreshPivot.show()
	$EnergyBar.hide()


func _on_area_2d_input_event(viewport, event, shape_idx):
	if $RefreshPivot.is_visible_in_tree() \
		and event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
		$RefreshPivot.hide()
		$EnergyBar.reset_energy()
		$EnergyBar.show()
		refreshed.emit()
