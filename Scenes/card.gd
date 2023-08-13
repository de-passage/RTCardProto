extends Node2D
class_name Card 

signal selected

@export var resource: CardResource: 
	set(value): 
		resource = value
		cardCost = value.cost
		cardName = value.cardName
		effects = _load_card_effects(resource.cardEffects)

var cardDescription: String: 
	set(value): 
		cardDescription = value
		$Values/Description.text = value

var cardName: String:
	set(value):
		$Values/Name.text = value
	get:
		return resource.cardName

var cardCost: int:
	set(value): 
		$Values/Cost.text = str(value)
	get:
		return resource.cost
		
var effects: Array[BaseEffect]:
	get: 
		return effects if effects != null else [BaseEffect.new()] 

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed: 
		selected.emit()

func update(player: PlayableEntity):
	var desc = ""
	for effect in effects: 
		desc += effect.get_description(player) + "\n"
	cardDescription = desc

func apply(player: PlayableEntity, enemy: PlayableEntity): 
	for effect in effects:
		effect.apply_effect(player, enemy)

func _load_card_effects(ef: Array[EffectResource]) -> Array[BaseEffect]: 
	var result: Array[BaseEffect] = []
	for e in ef: 
		var effect = e.effectScript.new(e.effectValues)
		if effect is BaseEffect: 
			if effect.has_method("accept_values"):
				effect.accept_values(e.effectValues)
			result.append(effect)
		else: 
			printerr("Failed to import effect!")
	return result
