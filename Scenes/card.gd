extends TextureButton
class_name Card 

signal selected(card: CardDeckInstance)
signal discarded(card: CardDeckInstance)

@onready var _cost = $Values/Cost as Label
@onready var _name = $Values/Name as Label
@onready var _tags = $Values/Tags as Label
@onready var _description = $Values/Description as Label
@onready var _icon_container = $MarginContainer/IconContainer as VBoxContainer
@onready var _mana_cost = $MarginContainer/IconContainer/ManaContainer/ManaCost as Label
@onready var _mana_template = $MarginContainer/IconContainer/ManaContainer as TextureRect

var _resource: CardDeckInstance

func get_effects() -> Array[BaseEffect]: 
	return _resource.on_play()
func get_values(): 
	return _resource.statuses()
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
	_mana_template.visible = resource.mana_cost() > 0
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
			
	for value in get_values():
		value.accept(self, context)

func add_description(s: String):
	_description.text += s + '\n'

func change_cost(cost: int):
	_cost.text = str(cost)

func _display_icon_list(icon_list):
	_icon_container.get_children().all(func(c): c.queue_free())
	_icon_container.add_child(_mana_template.duplicate)
	for icon in icon_list: 
		_icon_container.add_child(icon_list)

func apply(context: Context): 
	for effect in get_effects():
		effect.apply_effect(context)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				selected.emit(_resource)
			MOUSE_BUTTON_RIGHT:
				discarded.emit(_resource) 
		

func is_resource(card: CardDeckInstance):
	return card == _resource

func add_icon(_something):
	var label = Label.new()
	label.label_settings = LabelSettings.new()
	label.label_settings.font = preload("res://font/NeverMindsemi-serif-Regular.ttf")
	label.label_settings.font_size = 24
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = PRESET_FULL_RECT
	
