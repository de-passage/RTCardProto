extends BaseEffect

const DAMAGE = &"Damage"
const TRASH_AMOUNT = &"Trash Amount"
const TRASH = &"Trash"

var _damage: int = 5
var _trash_card: CardResource
var _trash_amount: int = 1

func _init(v: Dictionary):
	_damage = v.get(DAMAGE, 0)
	_trash_amount = v.get(TRASH_AMOUNT, 1)
	_trash_card = load(v.get(TRASH))

	description = "Attack for %s, if health would be lost, curse for the value"

func apply_effect(context: Context):
	var effect = _total_effect(context.source)
	var armor_removed = clampi(context.target.armor, 0, effect)
	effect -= armor_removed
	context.target.armor -= armor_removed
	if effect > 0:
		if _trash_card != null:
			context.trash(CardGameInstance.from_resource(_trash_card), Context.TRASH_DISCARD | Context.CURSE)
		else:
			printerr("null trash card in effect!")

func _total_effect(p: PlayableEntity):
	var total = _damage
	if p != null:
		total += p.strength
	return total

func get_description(context: Context):
	return description % _total_effect(context.source)

static func get_metadata():
	return {
		"name": "Cursed Strike",
		"parameters": [{
			"name": "Damage",
			"type": "int",
			"min": 0
		}, {
			"name": "Trash",
			"type": "card"
		}, {
			"name": "Trash Amount",
			"type": "int",
			"min": 1
		}]
	}

static func build_editor_input(p: EffectEditor.Proxy, params: Dictionary):
	p.add_int_input(DAMAGE, params.get(DAMAGE, 1))

static func editor_name():
	return "Cursed Strike"
