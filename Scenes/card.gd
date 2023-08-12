extends Node2D
class_name Card 

signal selected

@export var resource: CardResource: 
	set(value): 
		resource = value
		effect = value.effect.new() as BaseEffect
		cardCost = value.cost
		cardName = value.cardName
		cardDescription = value.cardDescription

var cardDescription: String: 
	set(value): 
		cardDescription = value
		$Values/Description.text = value

var cardName: String:
	set(value):
		cardName = value
		$Values/Name.text = value

var cardCost: int:
	set(value): 
		cardCost = value
		$Values/Cost.text = str(value)

var effect: BaseEffect

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed: 
		selected.emit()

func update(player: Player):
	cardDescription = effect.modify_description(cardDescription, player)

func apply(player: Player, enemy: Enemy): 
	effect.apply_effect(player, enemy)
