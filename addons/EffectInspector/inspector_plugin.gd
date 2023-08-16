extends EditorInspectorPlugin

func _can_handle(object):
	return object is CardResource

func _parse_category(object, category):
	if category != "Values":
		return
	add_property_editor("Effects", EffectsProperty.new(), true)
