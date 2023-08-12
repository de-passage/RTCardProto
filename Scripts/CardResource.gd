extends Resource

class_name CardResource

@export var cardName: String 
@export_multiline var cardDescription: String
@export var cost: int
@export var effect: Script

func update(player:Player): 
	cardDescription = effect.modify_description(cardDescription, player)
