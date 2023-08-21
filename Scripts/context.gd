extends RefCounted

class_name Context

var source: PlayableEntity
var target: PlayableEntity
var card: CardResource

func _init(card_: CardResource, source_: PlayableEntity, target_: PlayableEntity):
	source = source_
	card = card_
	target = target_

static func source_only(source_: PlayableEntity) -> Context: 
	return Context.new(null, source_, null)
