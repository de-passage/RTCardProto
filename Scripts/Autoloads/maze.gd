extends Node

## Number of floors (encounters) in a level (series of encounter with a boss at the end)
@export var level_floors: int = 11
## Level at which the guaranteed treasure appears. Negative or 0 value means never
@export var guaranteed_treasure_level: int = 5
## Chances of getting a normal encounter node
@export var normal_encounter_weight: int = 10
## Chances of getting an elite node
@export var elite_encounter_weight: int = 3
## Chances of getting a random treasure node
@export var treasure_weight: int = 0 
## Chances of getting a rest node
@export var rest_weight: int = 3
## Chances of getting a merchant node
@export var merchant_weight: int = 2
## Chances of getting a random event node
@export var random_event_weight: int = 5
## Minimum number of nodes per floor
@export var min_nodes: int = 2 
## Maximum number of nodes per floor
@export var max_nodes: int = 4
## Minimum number of floors with only normal or random encounters
@export var min_easy_nodes: int = 2

## Array of Array of NodeType. This corresponds to the floors with the rooms inside
var maze: Array[Array]

## Array of pairs (2-element array) of node positions (also pairs).
var connections = []

## Current position in the maze (floor, node)
var current_position = Vector2i(-1,-1)

enum NodeType { NORMAL, ELITE, MERCHANT, TREASURE, RANDOM, REST, ERROR }

func at(x, y) -> NodeType: 
	if x < 0 or y < 0 or x > maze.size(): 
		return NodeType.ERROR
	var fl = maze[x]
	if y > fl.size():
		return NodeType.ERROR
	return fl[y]

func generate_maze():
	clear()
	for i in range(0, level_floors):
		var weight_list: Array[Array]
		if i == guaranteed_treasure_level:
			weight_list = [[NodeType.TREASURE, 1]]
		elif i < min_easy_nodes: 
			weight_list = [
				[NodeType.NORMAL, normal_encounter_weight],
				[NodeType.RANDOM, random_event_weight]
			]
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

func get_maze():
	if maze == null or maze.is_empty(): 
		generate_maze()
	return maze 

## Create the full connection array between the floors 
func connect_all_floors():
	connections = []
	for floor_idx in range(maze.size() - 1):
		connections.append_array(connect_2_floors(floor_idx, floor_idx + 1))
		
func _choose_pivot(): 
	return randi() % 2
	
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

func clear(): 
	maze = []
	connections = []

func generate_new_level(): 
	generate_maze()
	current_position = Vector2(-1,-1)

func is_connected_to_player(fl, ro) -> bool: 
	if current_position.x == -1: 
		return fl == 0
		
	for connection in connections: 
		var start = connection[0]
		var end = connection[1]
		if same_as_player(start[0], start[1])\
			and fl == end[0] and ro == end[1]:
			return true
	return false;

func can_access_boss() -> bool: 
	return current_position.x == level_floors - 1

func move_to_boss() -> bool: 
	if can_access_boss():
		current_position = Vector2(-1,-1)
		return true
	return false

func move_player(fl, ro) -> bool:
	if is_connected_to_player(fl, ro): 
		current_position = Vector2(fl, ro)
		return true
	return false

func same_as_player(fl, ro) -> bool: 
	return fl == current_position.x and ro == current_position.y
