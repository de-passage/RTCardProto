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
	var result: Array[BaseEffect] = []
	for e in on_play_card_effects:
		var loaded = e.load_effect()
		if loaded != null: 
			result.append(loaded)
	return result
