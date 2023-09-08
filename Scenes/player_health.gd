extends HBoxContainer

@onready var _health = $CurrentHealth as Label
@onready var _health_icon = $HealthSprite as TextureRect
@onready var _armor = $CurrentArmor as Label
@onready var _armor_sprite = $ArmorSprite as TextureRect
@onready var _strength = $CurrentStrength as Label
@onready var _strength_sprite = $StrengthSprite as TextureRect
@onready var _steady = $SteadyDisplay as ValueDisplay

var current_armor = 0

func _display_health(): 
	var count: int = 0
	for card in Global.get_current_deck():
		for status in card.statuses():
			if status.get_name() == Statuses.WOUND:
				count += 1
	_health.text = str(count)
	_health.visible = count > 0
	_health_icon.visible = count > 0 

func _display_armor(): 
	if current_armor > 0: 
		_armor.text = str(current_armor)
		_armor.show()
		_armor_sprite.show()
	else:
		_armor_sprite.hide()
		_armor.hide()

func _display_if_positive(value: int, sprite: TextureRect, label: Label): 
	if value > 0: 
		label.text = str(value)
		label.show()
		sprite.show()
	else:
		label.hide()
		sprite.hide()
		
func armor_changed(a: int): 
	current_armor = max(0, a); 
	_display_armor()
	
func strength_changed(a: int):
	_display_if_positive(a, _strength_sprite, _strength)

func _redraw():
	_display_health() 
	_display_armor() 
		
## This function connects the values of tne Entity to the UI, 
## allowing them to be displayed and updated in real time 
## as they change
func connect_playable_entity(entity: PlayableEntity):
	current_armor = entity.armor
	strength_changed(entity.strength)
	
	if not entity.armor_changed.is_connected(armor_changed):
		entity.armor_changed.connect(armor_changed)
		Global.deck_changed.connect(_display_health)
		entity.strength_changed.connect(strength_changed)
		entity.steady_changed.connect(_steady.set_value)
	
	_redraw()

func _ready():
	_redraw()
