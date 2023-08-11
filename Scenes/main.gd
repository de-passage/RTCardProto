extends Node2D


func _on_energy_bar_step_reached(step):
	$UI/EnergyContainer/EnergyCount.text = "%s" % step
