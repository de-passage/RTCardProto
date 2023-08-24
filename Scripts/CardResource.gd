extends Resource

## This resource contains all the information a card needs to exist.
## Effects are specified in the array as subresources.
class_name CardResource

@export_category("Values")
@export var card_name: String 
@export var cost: int = 0
@export var on_play_card_effects: Array[EffectResource]
@export var on_draw_card_effects: Array[EffectResource]
@export var on_discard_card_effects: Array[EffectResource]
@export var monetary_value: int = 50
@export var rarity: int = 0
@export var tags: Array[StringName] = []

func load_card_effects() -> Array[BaseEffect]:
	return CardResource._load_effects(on_play_card_effects)
	
func load_on_draw_card_effects() -> Array[BaseEffect]:
	return CardResource._load_effects(on_draw_card_effects)
	
func load_on_discard_card_effects() -> Array[BaseEffect]:
	return CardResource._load_effects(on_discard_card_effects)

static func _load_effects(array: Array[EffectResource]) -> Array[BaseEffect]: 
	var result: Array[BaseEffect] = []
	for e in array:
		var loaded = e.load_effect()
		if loaded != null: 
			result.append(loaded)
	return result
