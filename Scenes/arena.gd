extends TextureRect

@onready var _monster_list = $MarginContainer/MainContainer/MonsterSelector/MonsterList/FlowContainer
@onready var _monster_presentation = $MarginContainer/MainContainer/MonsterSelector/MonsterDisplay/FlowContainer

var _monster_presentation_scene = preload("res://Scenes/monster_presentation.tscn")
var _effect_label_settings = preload("res://Theme/arena_effect_label_settings.tres")
var _resource 

func _ready():
	for monster in CGResourceManager.load_enemies():
		_add_monster_presenter(monster, _monster_list) \
			.selected.connect(_enemy_resource_selected)

func _add_monster_presenter(res: EnemyResource, list: Node) -> MonsterPresentation:
		var presenter = _monster_presentation_scene.instantiate() as MonsterPresentation
		list.add_child(presenter)
		presenter.initialize(res)
		return presenter

func _enemy_resource_selected(res: EnemyResource):
	for child in _monster_presentation.get_children():
		child.queue_free()
	
	_add_monster_presenter(res, _monster_presentation)
	_resource = res
	
	var effect_presentation = VBoxContainer.new()
	_monster_presentation.add_child(effect_presentation) 
	for card in res.effects:
		if card is CardResource:
			var effect_list = HBoxContainer.new()
			effect_presentation.add_child(effect_list)
			var effects = card.load_card_effects()
			for ef in effects:
				var label = Label.new()
				label.label_settings = _effect_label_settings
				label.text = ef.get_description(Context.new())
				effect_list.add_child(label)

func _on_start_button_pressed():
	if _resource == null: return 
	
	Global.set_current_enemy(_resource)
	Global.reset_current_deck()
	SceneManager.go_to_combat()


func _on_quit_button_pressed():
	SceneManager.exit_scene()
