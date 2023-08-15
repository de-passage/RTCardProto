extends TextureButton
class_name Card 

signal selected

var _resource: CardResource
var _effects: Array[BaseEffect]

func card_cost(): 
	return _resource.cost if _resource != null else 0  
		
func get_effects(): 
	return _effects if _effects != null else [BaseEffect.new()] 
		
func initialize(resource: CardResource, player: PlayableEntity):
	_resource = resource
	$Values/Cost.text = str(resource.cost)
	$Values/Name.text = resource.cardName
	_effects = resource.load_card_effects()
	update_description(player)

func update_description(player: PlayableEntity):
	var desc = ""
	for effect in _effects: 
		desc += effect.get_description(player) + "\n"
	$Values/Description.text = desc

func apply(player: PlayableEntity, enemy: PlayableEntity): 
	for effect in _effects:
		effect.apply_effect(player, enemy)

func _on_pressed():
	print("Selected: %s" % (_resource.cardName if _resource != null else $Values/Name.text) )
	selected.emit()
