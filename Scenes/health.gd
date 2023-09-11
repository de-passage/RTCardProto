extends Control

class_name StatusSynopsis

@export var max_health: int
@export var current_health: int

var current_armor = 0

func _display_health(): 
	$CurrentHealth.text = str(current_health) + '/' + str(max_health)

func _display_armor(): 
	if current_armor > 0: 
		$CurrentArmor.text = str(current_armor)
		$CurrentArmor.show()
		$ArmorSprite.show()
	else:
		$CurrentArmor.hide()
		$ArmorSprite.hide()

func _display_if_positive(value: int, sprite: TextureRect, label: Label): 
	if value > 0: 
		label.text = str(value)
		label.show()
		sprite.show()
	else:
		label.hide()
		sprite.hide()

func health_changed(h: int): 
	current_health = max(min(h, max_health), 0)
	_display_health()
		
func armor_changed(a: int): 
	current_armor = max(0, a); 
	_display_armor()

func max_health_changed(a: int): 
	max_health = a
	_display_health()
	
func strength_changed(a: int):
	_display_if_positive(a, $StrengthSprite, $CurrentStrength)

func _redraw():
	_display_health() 
	_display_armor() 
		
## This function connects the values of tne Entity to the UI, 
## allowing them to be displayed and updated in real time 
## as they change
func connect_playable_entity(entity: PlayableEntity):
	max_health = entity.max_hp
	current_health = entity.current_hp
	current_armor = entity.armor
	strength_changed(entity.strength)
	
	if not entity.armor_changed.is_connected(armor_changed):
		entity.armor_changed.connect(armor_changed)
		entity.current_hp_changed.connect(health_changed)
		entity.max_hp_changed.connect(max_health_changed)
		entity.strength_changed.connect(strength_changed)
	
	_redraw()
