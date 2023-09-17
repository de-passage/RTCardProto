extends BaseEffect

var _other_effects: Array[BaseEffect] # When combo triggers
var _normal_effects: Array[BaseEffect] # No combo case
var _last_subtype: String

const IF_TRUE = &"If true"
const OTHERWISE = &"Otherwise"
const TAG = &"Tag"

func _init(v: Dictionary):
	description = "Trigger another effect"

	var other_effects = v.get(IF_TRUE, null)
	if other_effects != null:
		_other_effects = []
		for e in other_effects:
			_other_effects.append(e.load_effect())
	else:
		# Backward compatibility with my own stupidity
		var ef = v.get("Effect", null) as EffectResource
		if ef != null:
			_other_effects = [ ef.load_effect() ]
		else:
			_other_effects = [ BaseEffect.new() ]

	var normal_effects = v.get(OTHERWISE)
	_normal_effects = []
	if normal_effects != null:
		for e in normal_effects:
			_normal_effects.append(e.load_effect())

	_last_subtype = v.get(TAG, "")

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
				"name": TAG
			},
			{
				"type": "effect",
				"name": IF_TRUE
			},
			{
				"type": "effect",
				"name": OTHERWISE
			}
		]
	}

static func editor_name():
	return "Combo"
