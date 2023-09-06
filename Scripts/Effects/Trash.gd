extends BaseEffect

var _trash_card: CardResource
var _trash_amount: int = 1

func _init(v: Dictionary): 
	_trash_amount = v.get("Trash Amount", 1)
	_trash_card = load(v.get("Trash"))
	
	description = "Add trash to discard"

func apply_effect(context: Context):
	if _trash_card:
		context.trash(CardGameInstance.from_resource(_trash_card), Context.TRASH_DISCARD | Context.CURSE)
	
func get_description(context: Context): 
	return description

static func get_metadata():
	return {
		"name": "Trash",
		"parameters": [{
			"name": "Trash",
			"type": "card"
		}, {
			"name": "Trash Amount",
			"type": "int",
			"min": 1
		}]
	}
