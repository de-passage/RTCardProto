extends Control

var effects: Array[Array] = []

func _redraw_effects():
	var list: ItemList = $GlobalContainer/EffectContainer
	list.clear()
	for effect in effects:
		var resource = Button.new()
		resource.text = effect[0] if effect != null else "<select>"
		list.add_child(resource)

func _on_spin_box_value_changed(value):
	while effects.size() < value:
		effects.append(null)
	
	effects.resize(value)
	_redraw_effects()
