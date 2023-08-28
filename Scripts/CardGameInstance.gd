extends CardDeckInstance

class_name CardGameInstance

var _source_instance: CardDeckInstance

func _init(card: CardDeckInstance): 
	super(card._base_card)
	_source_instance = card

func source_instance() -> CardGameInstance:
	return _source_instance

static func from_resource(r: CardResource) -> CardGameInstance:
	var d = CardDeckInstance.new(r)
	return CardGameInstance.new(d)
