@tool
extends Control

@onready var _control_panel = $EditorPanel as EditorControlPanel
@onready var _monster_editor_main_panel = $EditorPanel/MonsterEditorMainPanel as MonsterEditorMainPanel

const MONSTER_PATH = CGResourceManager.ENEMIES_PATH
const USER_MONSTER_PATH= "user://Monsters"

func _ready():
	_monster_editor_main_panel.load_available_cards()
	if not Engine.is_editor_hint():
		if not DirAccess.dir_exists_absolute(USER_MONSTER_PATH):
			DirAccess.make_dir_absolute(USER_MONSTER_PATH)
		_control_panel.access = FileDialog.ACCESS_USERDATA
		_control_panel.root_subfolder = USER_MONSTER_PATH
		
func attach_to_editor(editor: EditorInterface):
	_control_panel.attach_to_editor(editor)

func _on_file_dialog_file_selected(path):
	_monster_editor_main_panel.load_monster(path)

func _on_button_pressed():
	_monster_editor_main_panel.load_available_cards()

func _on_save_file_dialog_file_selected(path):
	_monster_editor_main_panel.save_monster(path)

func _on_reset_button_pressed():
	_monster_editor_main_panel.reset()

func _on_monster_name_changed(name: String):
	_control_panel.set_default_text("%s.tres" % name)
