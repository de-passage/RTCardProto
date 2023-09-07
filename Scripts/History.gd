extends RefCounted

class_name History

var _history: Array[HistoryPoint] = []

func card_played(card: CardDeckInstance):
	_add(HistoryPoint.played(card))

func card_drawn(card: CardDeckInstance):
	_add(HistoryPoint.drawn(card))
	
func card_exhausted(card: CardDeckInstance):
	_add(HistoryPoint.exhausted(card))

func card_discarded(card: CardDeckInstance):
	_add(HistoryPoint.discarded(card))

func card_purged(card: CardDeckInstance):
	_add(HistoryPoint.purged(card))
	
func last_card_played():
	var n: int  = _history.size() - 1
	while n >= 0:
		if _history[n].was_played():
			return _history[n].what
		n -= 1
	return null 

func last_n_cards_played() -> Array[CardDeckInstance]:
	var r = []
	var n: int = _history.size() - 1
	while n >= 0:
		if _history[n].was_played():
			r.append(_history[n].what)
		n -= 1
	return r

func _add(point: HistoryPoint):
	_history.append(point)
