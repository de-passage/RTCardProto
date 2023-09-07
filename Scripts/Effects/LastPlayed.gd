extends BaseEffect

var _other_effects: Array[BaseEffect]
var _last_subtype: String

func _init(v: Dictionary): 
	description = "Trigger another effect"
	var ef = v.get("Effect", null) as EffectResource
	if ef != null: 
		_other_effects = [ ef.load_effect() ]
	else:
		_other_effects = [ BaseEffect.new() ]
	_last_subtype = v.get("Tag", "")

func apply_effect(context: Context):
	var c = context.history().last_card_played()
	if c != null and c.has_tag(_last_subtype):
		for eff in _other_effects:
			eff.apply_effect(context)
	
func get_description(context: Context):
	var desc = "If last card was a %s: " % _last_subtype
	var n = _other_effects.size()
	if n > 0: 
		desc += _other_effects[0].get_description(context)
	n-=1
	for i in range(1, n):
		desc+=", " + _other_effects[i].get_description(context)
	
	return desc

static func get_metadata():
	return {
		"name": "Last Played",
		"parameters": [
			{	
				"type": "string",
				"name": "Tag"
			},
			{
				"type": "effect",
				"name": "Effect"
			}
		]
	}
