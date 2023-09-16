extends VBoxContainer

class_name MonsterPresentation

signal selected(res: EnemyResource)

@onready var _enemy_name = $MonsterName
@onready var _enemy_texture = $MonsterTexture

var _resource: EnemyResource

func initialize(res: EnemyResource):
	_resource = res 
	_enemy_name.text = res.name
	_enemy_texture.texture_normal = res.texture
	_enemy_texture.material = res.shader 


func _on_monster_texture_pressed():
	selected.emit(_resource)
