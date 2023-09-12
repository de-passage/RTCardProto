extends HBoxContainer

class_name DefenseDisplay

@onready var _defense = $CurrentDefense as Label
@onready var _defense_sprite = $DefenseSprite as TextureRect
@onready var _defense_progress_bar = $DefenseProgressBar as ProgressBar

var _entity = PlayableEntity.new(1)

func initialize(entity: PlayableEntity): 
	_entity = entity
	_defense_changed(entity.defense)
	_entity.defense_changed.connect(_defense_changed)
	TimeManager.time_changed.connect(_on_time_change)
	
func _defense_changed(value: int):
	if value > 0:
		_defense.text = str(value)
		_defense.show()
		_defense_sprite.show()
		_defense_progress_bar.visible = true
	else: 
		_defense.hide()
		_defense_sprite.hide()
		_defense_progress_bar.visible = false
		_defense_progress_bar.value = _defense_progress_bar.max_value

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
