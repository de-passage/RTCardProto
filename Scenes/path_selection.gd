extends Control

## Random deviation applied to the nodes from their normal position
@export var node_deviation = 32

var path_start_offset = 0.6
var added_children: Array[Array] = []
var added_lines = []

func _ready():
	
	$Circle.visible = false
	display_maze()
	$CanvasLayer/WhiteShader.material.get_shader_parameter("noise").noise.seed = randi()
	

func _random_deviation(): 
	return randi_range(-node_deviation, node_deviation)

func display_maze():
	# Calculate all the reference values
	var start_x = $MazeStart.position.x
	var end_x = $MazeEnd.position.x 
	var range_w = end_x - start_x
	var step_w = range_w / (Maze.level_floors - 1)
	var start_y = $MazeTop.position.y
	var end_y = $MazeBottom.position.y
	var range_h = end_y - start_y
	
	# Display the nodes
	var current_floor = 0
	for maze_floor in Maze.get_maze():
		var step_y = range_h / (maze_floor.size() - 1)
		var current_x = start_x + step_w * current_floor
		
		var current_node = 0
		var current_floor_children = []
		added_children.append(current_floor_children)
		for room in maze_floor:
			var sprite: TextureButton = instanciate_node(room)
			current_floor_children.append(sprite)
			var current_y = start_y + current_node * step_y
			
			sprite.position = Vector2(\
				current_x + _random_deviation() - _texture_dim(sprite) / 2,\
				current_y + _random_deviation() - _texture_dim(sprite) / 2)
			sprite.pressed.connect(_on_sprite_button_pressed.bind(current_floor, current_node))
			
			if Maze.same_as_player(current_floor, current_node):
				$Circle.position = \
					Vector2(sprite.position.x + _texture_dim(sprite) / 2, \
							sprite.position.y + _texture_dim(sprite) / 2)
				$Circle.visible = true
			current_node += 1
			
		current_floor += 1
			
	# Display the connections between generated nodes
	for connection in Maze.connections: 
		var left_point_ref = connection[0]
		var right_point_ref = connection[1]
		var left = added_children[left_point_ref[0]][left_point_ref[1]]
		var right = added_children[right_point_ref[0]][right_point_ref[1]]
		_draw_line(left, right)
	
	# Display the connections between the last nodes and the boss
	for room in added_children[added_children.size() - 1]: 
		_draw_line(room, $Boss)

func _texture_dim(t: TextureButton): 
	return t.get_rect().size.x

func _texture_center(t: TextureButton): 
	return Vector2(t.position.x + _texture_dim(t) / 2,\
				t.position.y + _texture_dim(t) / 2)

func _draw_line(left: TextureButton, right: TextureButton):
	var newNode = Line2D.new()
	var lpos = _texture_center(left)
	var rpos = _texture_center(right)
	var ldim = _texture_dim(left) * path_start_offset
	var rdim = _texture_dim(right) * path_start_offset
	
	newNode.add_point(lpos.move_toward(rpos, ldim))
	newNode.add_point(rpos.move_toward(lpos, rdim))
	add_child(newNode)
	newNode.antialiased = true
	added_lines.append(newNode)

func instanciate_node(node: Maze.NodeType):
	var sprite;
	match node:
		Maze.NodeType.NORMAL:
			sprite = $Enemy.duplicate()
		Maze.NodeType.ELITE:
			sprite = $Elite.duplicate()
		Maze.NodeType.TREASURE:
			sprite = $Treasure.duplicate()
		Maze.NodeType.MERCHANT:
			sprite = $Merchant.duplicate()
		Maze.NodeType.REST:
			sprite = $Rest.duplicate()
		Maze.NodeType.RANDOM:
			sprite = $Random.duplicate()
	add_child(sprite)
	sprite.visible = true
			
	return sprite
	
func _on_button_pressed():
	Maze.clear()
	for child in added_children:
		for subchild in child:
			subchild.queue_free()
	for line in added_lines: 
		line.queue_free()
	added_lines.clear()
	added_children.clear()
	Maze.generate_maze()
	display_maze()	


func _on_boss_pressed():
	if Maze.move_to_boss():
		start_combat(Global.EnemyPool.BOSS)

func _on_sprite_button_pressed(f, n): 
	if Maze.move_player(f, n):
		print("Moving to node %s,%s" % [f,n])
		var chosen_cell: Maze.NodeType = Maze.at(f,n)
		match chosen_cell:
			Maze.NodeType.ELITE:
				start_combat(Global.EnemyPool.ELITE)
			Maze.NodeType.NORMAL:
				start_combat(Global.EnemyPool.NORMAL)
			Maze.NodeType.RANDOM:
				start_combat(Global.EnemyPool.NORMAL)
			Maze.NodeType.MERCHANT: 
				start_combat(Global.EnemyPool.NORMAL)
			Maze.NodeType.TREASURE:
				start_combat(Global.EnemyPool.NORMAL)
			Maze.NodeType.REST:
				get_tree().change_scene_to_file("res://Scenes/rest.tscn")

func start_combat(enemy_type: Global.EnemyPool):
	print("combat started")
	Global.setup_random_enemy(Global.current_level, enemy_type)
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_hud_please_exit():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
