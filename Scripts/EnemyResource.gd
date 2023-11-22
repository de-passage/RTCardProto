extends Resource

class_name EnemyResource

@export var name: String
@export var health: int = 10
@export var effects: Array[CardResource]
@export var coin_value: int = 10
@export var texture: Texture2D
@export var shader: ShaderMaterial
@export var attack_frequency: float = 5
@export var card_reward = true
@export var max_posture: int = 3

@export var type: Global.EnemyPool = Global.EnemyPool.NORMAL
@export var level: Global.LevelPool = Global.LevelPool.DEFAULT
