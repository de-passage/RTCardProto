extends TextureButton
class_name Card 

signal selected

@onready var _cost = $Values/Cost
@onready var _name = $Values/Name
@onready var _tags = $Values/Tags
@onready var _description = $Values/Description

var _resource: CardResource
var _effects: Array[BaseEffect]
var _on_discard: Array[BaseEffect]
var _on_draw: Array[BaseEffect]

func card_cost() -> int: 
	return _resource.cost if _resource != null else 0  
		
func get_effects() -> Array[BaseEffect]: 
	return _effects if _effects != null else [BaseEffect.new()] 
func get_on_draw_effects() -> Array[BaseEffect]: 
	return _on_draw if _on_draw != null else [BaseEffect.new()] 
func get_on_discard_effects() -> Array[BaseEffect]: 
	return _on_discard if _on_discard != null else [BaseEffect.new()] 
		
func initialize(resource: CardResource, player: PlayableEntity):
	_resource = resource
	_cost.text = str(resource.cost)
	_name.text = resource.card_name
	_tags.text = ','.join(resource.tags)
	_effects = resource.load_card_effects()
	_on_draw = resource.load_on_draw_card_effects()
	_on_discard = resource.load_on_discard_card_effects()
	update_description(Context.source_only(player))

func update_description(context: Context):
	var desc = ""
	for effect in _effects: 
		desc += effect.get_description(context) + "\n"
		
	if _on_discard.size() > 0:
		desc+="On discard: "
		for e in _on_discard:
			desc+=e.get_description(context) + '\n'
			
	if _on_draw.size() > 0:
		desc+="On draw: "
		for e in _on_draw:
			desc+=e.get_description(context) + '\n' 
			
	_description.text = desc

func apply(context: Context): 
	for effect in _effects:
		effect.apply_effect(context)

func _on_pressed():
	# print("Selected: %s" % (_resource.card_name if _resource != null else $Values/Name.text) )
	selected.emit()
