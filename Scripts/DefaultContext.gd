extends Context

class_name DefaultPlayerContext

func trash(what: CardGameInstance, where: int = Context.CURSE) -> void:
	if (where & Context.CURSE) > 0:
		Global.add_to_current_deck(what.source_instance())
