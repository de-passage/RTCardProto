@tool
extends ScrollContainer

@onready var _card_editor_main_panel = $EditorPanel/CardEditorMainPanel as CardEditorMainPanel
@onready var _editor_panel = $EditorPanel as EditorControlPanel

var _resources: Array
const USER_CARD_PATH = "user://Cards"

func _ready():
	if not Engine.is_editor_hint():
		if not DirAccess.dir_exists_absolute(USER_CARD_PATH):
			DirAccess.make_dir_absolute(USER_CARD_PATH)
		_editor_panel.access = FileDialog.ACCESS_USERDATA
		_editor_panel.root_subfolder = USER_CARD_PATH

func _get_file_path(s):
	return "res://Cards/%s.tres" % s

func _on_reset_button_pressed():
	_card_editor_main_panel.reset_state()

func attach_to_editor(editor: EditorInterface):
	_editor_panel.attach_to_editor(editor)


# #################################
# SIGNALS
###################################
	
func _on_file_dialog_file_selected(path: String):
	_card_editor_main_panel.load_card_from_path(path)

func _on_editor_panel_save_required(path):
	_card_editor_main_panel.save_resource(path)
