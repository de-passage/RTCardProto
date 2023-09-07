extends RefCounted

class_name HistoryPoint

enum ActionType {
	PLAYED,
	DRAWN,
	DISCARDED,
	EXHAUSTED,
	PURGED
}

@export var what: CardDeckInstance 
@export var how: ActionType
@export var when: float

func _init(card: CardDeckInstance, action: ActionType):
	what = card.copy()
	how = action
	when = Time.get_unix_time_from_system()

func was_played() -> bool: 
	return how == ActionType.PLAYED

static func played(card: CardDeckInstance):
	return HistoryPoint.new(card, ActionType.PLAYED)

static func discarded(card: CardDeckInstance):
	return HistoryPoint.new(card, ActionType.DISCARDED)

static func exhausted(card: CardDeckInstance):
	return HistoryPoint.new(card, ActionType.EXHAUSTED)

static func purged(card: CardDeckInstance):
	return HistoryPoint.new(card, ActionType.PURGED)

static func drawn(card: CardDeckInstance):
	return HistoryPoint.new(card, ActionType.DRAWN)
