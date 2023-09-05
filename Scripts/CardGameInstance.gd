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

func on_play() -> Array[BaseEffect]:
	return _source_instance.on_play()

func on_exhaust() -> Array[BaseEffect]:
	return _source_instance.on_exhaust()
	
func on_discard() -> Array[BaseEffect]:
	return _source_instance.on_discard()
	
func on_draw() -> Array[BaseEffect]:
	return _source_instance.on_draw()

func energy_cost() -> int: 
	return _source_instance.energy_cost()

func mana_cost() -> int: 
	return _source_instance.mana_cost()

func card_name() -> String:
	return _source_instance.card_name()

func tags() -> Array[StringName]:
	return _source_instance.tags()

func playable() -> bool: 
	return _source_instance.playable()

func get_resource() -> CardResource: 
	return _source_instance.get_resource()

func statuses() -> Array[BaseStatus]:
	return _source_instance._statuses
