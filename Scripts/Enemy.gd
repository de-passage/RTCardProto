extends PlayableEntity

class_name EnemyEntity

signal broken()
signal posture_changed(value: int)
signal max_posture_changed(value: int)

var posture: int = 0:
    set(value):
        var new_value = clamp(value, 0, max_posture)
        var old_value = posture
        posture = new_value

        if new_value == 0 and old_value != 0:
            broken.emit()

        if old_value != new_value:
            posture_changed.emit(value)
    get:
        return posture

var max_posture: int = 0: 
    set(value):
        max_posture = value
        max_posture_changed.emit(value)
    get:
        return max_posture


func _init(health: int):
    super._init(health)

func wound(hp_loss: int):
    super.wound(hp_loss)
    posture -= 1