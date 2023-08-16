extends EditorProperty
class_name EffectsProperty

func _ready():
	label = "Effects"
	var effectCount = load("res://addons/EffectInspector/effect_editor.tscn").instantiate()
	add_child(effectCount)
