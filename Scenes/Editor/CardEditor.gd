extends Control

@onready var _card_editor = %CardEditorMainPanel as CardEditorMainPanel

func _on_exit_button_pressed():
	SceneManager.exit_scene()


func _on_editor_panel_load_required(path):
	_card_editor.load_card_from_path(path)


func _on_editor_panel_new_required():
	_card_editor.reset_state()

func _on_editor_panel_save_required(path):
	_card_editor.save_resource(path)
