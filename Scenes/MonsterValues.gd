extends Control

class_name StatusSynopsis

@onready var _common_values = $CommonValueDisplay as CommonValueDisplay
@onready var _health = $HealthDisplay as ValueDisplayWithMax

## This function connects the values of tne Entity to the UI, 
## allowing them to be displayed and updated in real time 
## as they change
func connect_playable_entity(entity: PlayableEntity):
	if not entity.current_hp_changed.is_connected(_health.set_value):
		entity.current_hp_changed.connect(_health.set_value)
		entity.max_hp_changed.connect(_health.set_max_value)
		_common_values.connect_playable_entity(entity)
		
		_health.set_max_value(entity.max_hp)
		_health.set_value(entity.current_hp)
	
