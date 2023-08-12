extends Control

signal health_changed(value: int)
signal died

@export var max_health: int
@export var current_health: int

var current_armor = 0

func _display_health(): 
	$CurrentHealth.text = str(current_health) + '/' + str(max_health)

func _ready(): 
	_display_health() 
	$CurrentArmor.hide()
	$ArmorSprite.hide()

func set_health(h: int): 
	current_health = max(min(h, max_health), 0)
	health_changed.emit(current_health)
	_display_health()
	if current_health == 0: 
		died.emit()
		
func add_armor(a: int):
	current_armor += a;
	if current_armor <= 0:
		current_armor = 0
		return
	$CurrentArmor.text = str(current_armor)
	$CurrentArmor.show()
	$ArmorSprite.show()

func damage(value: int):
	current_armor -= value
	if current_armor > 0:
		$CurrentArmor.text = str(current_armor)
		return
	elif current_armor <= 0:
		value = -current_armor
		current_armor = 0
		$CurrentArmor.hide()
		$ArmorSprite.hide()
		set_health(current_health - value)
		
	
func heal(restored: int):
	set_health(current_health + restored)
	
