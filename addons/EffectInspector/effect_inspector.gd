@tool
extends EditorPlugin

var plugin

func _enter_tree():
	load_plugin() 
	
func _exit_tree():
	unload_plugin()

func unload_plugin():
	remove_inspector_plugin(plugin)

func load_plugin(): 
	plugin = preload("res://addons/EffectInspector/inspector_plugin.gd").new()
	add_inspector_plugin(plugin)
	
func reload_plugin():
	unload_plugin()
	load_plugin()
	
func _input(event):
	if event.is_action("reload_plugin_scene") and event.is_pressed():
		reload_plugin()
