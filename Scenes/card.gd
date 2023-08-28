extends TextureButton
class_name Card 

signal selected
signal discarded

@onready var _cost = $Values/Cost
@onready var _name = $Values/Name
@onready var _tags = $Values/Tags
@onready var _description = $Values/Description
@onready var _mana_cost = $ManaContainer/ManaCost

var _resource: CardDeckInstance

func get_effects() -> Array[BaseEffect]: 
	return _resource.on_play()
func get_on_draw_effects() -> Array[BaseEffect]: 
	return _resource.on_draw()
func get_on_discard_effects() -> Array[BaseEffect]: 
	return _resource.on_discard()

func energy_cost() -> int: 
	return _resource.energy_cost() if _resource != null else 0
		
func initialize(resource: CardDeckInstance, player: PlayableEntity):
	_resource = resource
	_cost.text = str(resource.energy_cost())
	_mana_cost.text = str(resource.mana_cost())
	_name.text = resource.card_name()
	_tags.text = ','.join(resource.tags())
	update_description(Context.source_only(player))

func update_description(context: Context):
	var desc = ""
	if not _resource.playable():
		desc = "Unplayable\n"
		
	for effect in get_effects(): 
		desc += effect.get_description(context) + "\n"
		
	if get_on_discard_effects().size() > 0:
		desc+="On discard: "
		for e in get_on_discard_effects():
			desc+=e.get_description(context) + '\n'
			
	if get_on_draw_effects().size() > 0:
		desc+="On draw: "
		for e in get_on_draw_effects():
			desc+=e.get_description(context) + '\n' 
			
	_description.text = desc

func apply(context: Context): 
	for effect in get_effects():
		effect.apply_effect(context)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				selected.emit()
			MOUSE_BUTTON_RIGHT:
				discarded.emit() 
		
