extends HBoxContainer

@onready var _health = $Label as Label
@onready var _health_icon = $Icon as TextureRect

func _ready(): 
	Global.deck_changed.connect(_display_health)
	_display_health()

func _display_health(): 
	var count: int = 0
	for card in Global.get_current_deck():
		for status in card.statuses():
			if status.get_name() == Statuses.WOUND:
				count += 1
	_health.text = str(count)
	_health.visible = count > 0
	_health_icon.visible = count > 0 
