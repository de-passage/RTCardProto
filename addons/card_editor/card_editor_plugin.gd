@tool
extends EditorPlugin

var card_editor

func _enter_tree():
	load_scene()
	InputMap.add_action("reload_plugin_scene")
	var event = InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_F4
	InputMap.action_add_event("reload_plugin_scene", event)
	
	
func _exit_tree():
	InputMap.erase_action("reload_plugin_scene")
	unload_scene()
	
func reload_scene():
	print("reloaded")
	unload_scene()
	load_scene()

func load_scene(): 	
	card_editor = preload("res://addons/card_editor/card_editor.tscn").instantiate()
	add_control_to_bottom_panel(card_editor, "Card Editor")

func unload_scene():
	if card_editor: 
		remove_control_from_bottom_panel(card_editor)
		card_editor.queue_free()
		card_editor = null

func _make_visible(visible):
	if card_editor:
		card_editor.visible = visible
		
func _get_plugin_name():
	return "Card Editor"
	
func _input(event):
	if event.is_action("reload_plugin_scene") and event.is_pressed():
		reload_scene()
