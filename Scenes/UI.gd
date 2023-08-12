extends CanvasLayer

func _on_energy_bar_step_reached(step):
	$EnergyContainer/EnergyCount.text = str(step)
