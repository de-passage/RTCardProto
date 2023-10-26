extends Control

@onready var _monster_editor = %MonsterEditorMainPanel as MonsterEditorMainPanel

func _on_exit_button_pressed():
	SceneManager.exit_scene()

func _on_editor_panel_load_required(path):
	_monster_editor.load_monster(path)


func _on_editor_panel_new_required():
	_monster_editor.reset()

func _on_editor_panel_save_required(path):
	_monster_editor.save_monster(path)
