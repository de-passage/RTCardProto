extends Resource

## This resource contains all the information a card needs to exist.
## Effects are specified in the array as subresources.
class_name CardResource

@export_category("Values")
@export var cardName: String 
@export var cost: int = 0
@export var cardEffects: Array[EffectResource]
@export var monetaryValue: int = 50
@export var rarity: int = 0

func load_card_effects() -> Array[BaseEffect]: 
	var result: Array[BaseEffect] = []
	for e in cardEffects: 
		result.append(e.load_effect())
	return result
