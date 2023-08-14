extends Resource

class_name EnemyResource

@export var name: String
@export var health: int = 10
@export var effects: Array[EffectResource]
@export var coin_value: int = 10
@export var texture: Texture2D
@export var shader: ShaderMaterial
@export var attack_frequency: float = 5
