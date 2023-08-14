extends Node2D

## Number of floors (encounters) in a level (series of encounter with a boss at the end)
@export var level_floors = 11
## Level at which the guaranteed treasure appears. Negative or 0 value means never
@export var guaranteed_treasure_level = 5
## Chances of getting a normal encounter node
@export var normal_encounter_weight = 10
## Chances of getting an elite node
@export var elite_encounter_weight = 3
## Chances of getting a random treasure node
@export var treasure_weight = 0 
## Chances of getting a rest node
@export var rest_weight = 3
## Chances of getting a merchant node
@export var merchant_weight = 2
## Chances of getting a random event node
@export var random_event_weight = 5
## Minimum number of nodes per floor
@export var min_nodes = 2 
## Maximum number of nodes per floor
@export var max_nodes = 4

## Weights pivot selection in the path generation algorithm
@export var path_pivot_bias = 0 

## Random deviation applied to the nodes from their normal position
@export var node_deviation = 32

var path_start_offset = 0.6

## Current position in the maze (floor, node)
var current_position = Vector2i(0,0)

enum NodeType { NORMAL, ELITE, MERCHANT, TREASURE, RANDOM, REST }
var maze: Array[Array] = []
var connections = []
var added_children: Array[Array] = []
var added_lines = []

func _enter_tree():
	generate_maze()
	display_maze()

func _ready():
	$CanvasLayer/WhiteShader.material.get_shader_parameter("noise").noise.seed = randi()
	
func generate_maze():
	for i in range(0, level_floors):
		var weight_list: Array[Array]
		if i == guaranteed_treasure_level:
			weight_list = [[NodeType.TREASURE, 1]]
		else:
			weight_list = [
				[NodeType.TREASURE, treasure_weight],
				[NodeType.ELITE, elite_encounter_weight],
				[NodeType.NORMAL, normal_encounter_weight],
				[NodeType.RANDOM, random_event_weight],
				[NodeType.REST, rest_weight],
				[NodeType.MERCHANT, merchant_weight]
			]
		maze.append(generate_floor(weight_list))
	connect_all_floors()

func generate_floor(weights: Array[Array]) -> Array[NodeType]: 
	var nodes: Array[NodeType] = []
	var weight_sum = 0
	for weight in weights:
		weight_sum += weight[1]
		
	for node in range(0, randi_range(min_nodes, max_nodes)): 
		var result = randi_range(0, weight_sum)
		var current_choice = NodeType.NORMAL
		for weight in weights:
			result -= weight[1] 
			current_choice = weight[0]
			if result <= 0: break
		nodes.append(current_choice)
	
	return nodes
	
## Create the full connection array between the floors 
func connect_all_floors():
	connections = []
	for floor_idx in range(maze.size() - 1):
		connections.append_array(connect_2_floors(floor_idx, floor_idx + 1))
		
func _choose_pivot(): 
	var choice = randi_range(-100, 100)
	return 0 if choice + path_pivot_bias >= 0 else 1
	
## Create the connections between 2 floors 
##
## This is a sweep algorithm "descending" through the nodes. 
## It starts with a random pivot at one of the edges, then
## connect it in order to the nodes on the other sides. 
## The pivot change sides randomly, until we've reached the end 
func connect_2_floors(left: int, right: int):
	var result = []
	var left_floor = maze[left]
	var right_floor = maze[right]
	
	const LEFT=0
	const RIGHT=1
	var last_left = left_floor.size() - 1
	var last_right = right_floor.size() - 1
	var current_edge = [0, 0]
	var pivot = _choose_pivot()
	
	while current_edge[LEFT] != last_left \
		or current_edge[RIGHT] != last_right:
		result.append([[left, current_edge[LEFT]], [right, current_edge[RIGHT]]])
		
		if current_edge[LEFT] == last_left: 
			pivot = RIGHT 
		elif current_edge[RIGHT] == last_right:
			pivot = LEFT 
		else: 
			pivot = _choose_pivot()
		
		current_edge[pivot] += 1
	
	# We leave the loop before processing the last edge connecting 
	# the bottom-most nodes
	result.append([[left, last_left], [right, last_right]])
	
	return result

func _random_deviation(): 
	return randi_range(-node_deviation, node_deviation)

func display_maze():
	# Calculate all the reference values
	var start_x = $MazeStart.position.x
	var end_x = $MazeEnd.position.x 
	var range_w = end_x - start_x
	var step_w = range_w / (level_floors - 1)
	var start_y = $MazeTop.position.y
	var end_y = $MazeBottom.position.y
	var range_h = end_y - start_y
	
	# Display the nodes
	var current_floor = 0
	for maze_floor in maze:
		var step_y = range_h / (maze_floor.size() - 1)
		var current_x = start_x + step_w * current_floor
		current_floor += 1
		
		var current_node = 0
		var current_floor_children = []
		added_children.append(current_floor_children)
		for room in maze_floor:
			var sprite: TextureButton = instanciate_node(room, current_floor, current_node)
			current_floor_children.append(sprite)
			var current_y = start_y + current_node * step_y
			current_node += 1
			
			sprite.position = Vector2(\
				current_x + _random_deviation() - _texture_dim(sprite) / 2,\
				current_y + _random_deviation() - _texture_dim(sprite) / 2)
			sprite.pressed.connect(_on_sprite_button_pressed.bind(current_floor, current_node))
			
	# Display the connections between generated nodes
	for connection in connections: 
		var left_point_ref = connection[0]
		var right_point_ref = connection[1]
		var left = added_children[left_point_ref[0]][left_point_ref[1]]
		var right = added_children[right_point_ref[0]][right_point_ref[1]]
		_draw_line(left, right)
	
	# Display the connections between the last nodes and the boss
	for room in added_children[added_children.size() - 1]: 
		_draw_line(room, $Boss)
		
func _on_sprite_button_pressed(f, n): 
	print("Pressed: (%s,%s)" % [f,n])

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

func instanciate_node(node: NodeType, _current_floor, _current_node):
	var sprite;
	match node:
		NodeType.NORMAL:
			sprite = $Enemy.duplicate()
		NodeType.ELITE:
			sprite = $Elite.duplicate()
		NodeType.TREASURE:
			sprite = $Treasure.duplicate()
		NodeType.MERCHANT:
			sprite = $Merchant.duplicate()
		NodeType.REST:
			sprite = $Rest.duplicate()
		NodeType.RANDOM:
			sprite = $Random.duplicate()
	add_child(sprite)
	sprite.visible = true
			
	return sprite
	
func _on_button_pressed():
	maze.clear()
	for child in added_children:
		for subchild in child:
			subchild.queue_free()
	for line in added_lines: 
		line.queue_free()
	added_lines.clear()
	added_children.clear()
	generate_maze()
	display_maze()	
