extends HBoxContainer

@onready var _common = $CommonValueDisplay as CommonValueDisplay

func connect_playable_entity(entity: PlayableEntity):
	_common.connect_playable_entity(entity)
