extends HBoxContainer
class_name CommonValueDisplay

@onready var _armor = $ArmorDisplay as ValueDisplay
@onready var _strength = $StrengthDisplay as ValueDisplay
@onready var _steady = $SteadyDisplay as ValueDisplay
@onready var _defense = $DefenseDisplay as DefenseDisplay
		
## This function connects the values of tne Entity to the UI, 
## allowing them to be displayed and updated in real time 
## as they change
func connect_playable_entity(entity: PlayableEntity):
	if not entity.armor_changed.is_connected(_armor.set_value):
		entity.armor_changed.connect(_armor.set_value)
		entity.strength_changed.connect(_strength.set_value)
		entity.steady_changed.connect(_steady.set_value)
		_defense.initialize(entity)
