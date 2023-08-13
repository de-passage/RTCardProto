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

## Current position in the maze (floor, node)
var current_position = Vector2i(0,0)

enum NodeType { NORMAL, ELITE, MERCHANT, TREASURE, RANDOM, REST }
var maze: Array[Array] = []
var added_children = []

func _enter_tree():
	generate_maze()
	display_maze()
	
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

func display_maze():
	var start_x = $MazeStart.position.x
	var end_x = $MazeEnd.position.x 
	var range_w = end_x - start_x
	var step_w = range_w / (level_floors - 1)
	var start_y = $MazeTop.position.y
	var end_y = $MazeBottom.position.y
	var range_h = end_y - start_y
	
	var current_floor = 0
	for nodes in maze:
		var step_y = range_h / (nodes.size() - 1)
		var current_x = start_x + step_w * current_floor
		current_floor += 1
		
		var current_node = 0
		for node in nodes:
			var sprite: Sprite2D = instanciate_node(node)
			var current_y = start_y + current_node * step_y
			current_node += 1
			
			sprite.position = Vector2(current_x, current_y)
			sprite.visible = true
			add_child(sprite)
			added_children.append(sprite)
		

func instanciate_node(node: NodeType):
	match node:
		NodeType.NORMAL:
			return $Enemy.duplicate()
		NodeType.ELITE:
			return $Elite.duplicate()
		NodeType.TREASURE:
			return $Treasure.duplicate()
		NodeType.MERCHANT:
			return $Merchant.duplicate()
		NodeType.REST:
			return $Rest.duplicate()
		NodeType.RANDOM:
			return $Random.duplicate()

func _on_button_pressed():
	maze.clear()
	for child in added_children:
		child.queue_free()
	added_children.clear()
	generate_maze()
	display_maze()
	
