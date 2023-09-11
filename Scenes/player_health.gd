extends HBoxContainer

@onready var _health = $CurrentHealth as Label
@onready var _health_icon = $HealthSprite as TextureRect
@onready var _armor = $CurrentArmor as Label
@onready var _armor_sprite = $ArmorSprite as TextureRect
@onready var _defense = $CurrentDefense as Label
@onready var _defense_sprite = $DefenseSprite as TextureRect
@onready var _defense_progress_bar = $DefenseProgressBar
@onready var _strength = $CurrentStrength as Label
@onready var _strength_sprite = $StrengthSprite as TextureRect
@onready var _steady = $SteadyDisplay as ValueDisplay

var _entity = PlayableEntity.new(1)

func _display_health(): 
	var count: int = 0
	for card in Global.get_current_deck():
		for status in card.statuses():
			if status.get_name() == Statuses.WOUND:
				count += 1
	_health.text = str(count)
	_health.visible = count > 0
	_health_icon.visible = count > 0 


func _display_if_positive(value: int, sprite: TextureRect, label: Label): 
	if value > 0: 
		label.text = str(value)
		label.show()
		sprite.show()
	else:
		label.hide()
		sprite.hide()
		
func armor_changed(a: int): 
	_display_if_positive(a, _armor_sprite, _armor)
	
func _defense_changed(value: int):
	_display_if_positive(value, _defense_sprite, _defense)
	if value > 0:
		_defense_progress_bar.visible = true
	else: 
		_defense_progress_bar.visible = false
		_defense_progress_bar.value = _defense_progress_bar.max_value
		
func strength_changed(a: int):
	_display_if_positive(a, _strength_sprite, _strength)

func _redraw():
	_display_health() 
		
## This function connects the values of tne Entity to the UI, 
## allowing them to be displayed and updated in real time 
## as they change
func connect_playable_entity(entity: PlayableEntity):
	_entity = entity
	
	strength_changed(entity.strength)
	_defense_changed(entity.defense)
	armor_changed(entity.armor)
	
	if not entity.armor_changed.is_connected(armor_changed):
		entity.armor_changed.connect(armor_changed)
		Global.deck_changed.connect(_display_health)
		entity.strength_changed.connect(strength_changed)
		entity.steady_changed.connect(_steady.set_value)
		entity.defense_changed.connect(_defense_changed)
	
	_redraw()

func _ready():
	_redraw()
	TimeManager.time_changed.connect(_on_time_change)

func _on_time_change(delta: float): 
	if _entity.defense > 0:
		var change = delta * _defense_progress_bar.max_value
		while change > 0: 
			var effective_change = min(change, _defense_progress_bar.value)
			_defense_progress_bar.value -= effective_change
			change -= effective_change
			if _defense_progress_bar.value == 0.:
				_defense_progress_bar.value = _defense_progress_bar.max_value
				_entity.defense -= 1 
