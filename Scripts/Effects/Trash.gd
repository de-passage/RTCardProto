extends BaseEffect

const TRASH = &"Trash"
const TRASH_AMOUNT = &"Trash Amount"

var _trash_card: CardResource
var _trash_amount: int = 1

func _init(v: Dictionary):
	_trash_amount = v.get("Trash Amount", 1)
	_trash_card = load(v.get("Trash"))

	description = "Add trash to discard"

func apply_effect(context: Context):
	if _trash_card:
		context.trash(CardGameInstance.from_resource(_trash_card), Context.TRASH_DISCARD | Context.CURSE)

func get_description(_context: Context):
	return description

static func build_editor_input(p: EffectEditor.Proxy, params: Dictionary):
	var amount = p.add_int_input(TRASH_AMOUNT, params.get(TRASH_AMOUNT, 1))
	p.add_card_input(TRASH, params.get(TRASH))
	
	amount.min_value = 1
	
static func editor_name():
	return "Trash"
