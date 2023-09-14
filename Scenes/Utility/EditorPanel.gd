extends VBoxContainer

signal save_required(path: String)
signal load_required(path: String)
signal new_required()

@export var root_subfolder: StringName
@export var access: FileDialog.Access

@onready var _file_dialog = $MenuBar/FileDialog as FileDialog

func _ready(): 
	if access != null:
		_file_dialog.access = access
		
	if root_subfolder != null: 
		_file_dialog.root_subfolder = root_subfolder

func _on_save_button_pressed():
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.popup_centered_ratio()

func _on_load_button_pressed():
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.popup_centered_ratio()

func _on_file_dialog_file_selected(path):
	match _file_dialog.file_mode:
		FileDialog.FILE_MODE_SAVE_FILE: save_required.emit(path)
		FileDialog.FILE_MODE_OPEN_FILE: load_required.emit(path)


func _on_new_button_pressed():
	new_required.emit()
	_file_dialog.get_line_edit().clear()
