extends Resource

## This resource holds an effect (script) and the instance values 
## that are attached to it. It allows to have the same effect with 
## different intensities on different cards. The number of values 
## cannot be simply tied to the effect in the Inspector, so you'll
## have to be careful
class_name EffectResource

@export var effectValues: Array[int]
@export var effectScript: Script
