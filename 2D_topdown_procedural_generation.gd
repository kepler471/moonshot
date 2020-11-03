extends Node2D

const TILE_SIZE = 32

const LEVEL_SIZES = [
	Vector2(50, 50),
	Vector2(50, 50),
	Vector2(50, 50),
	Vector2(50, 50),
	Vector2(50, 50)
]

const LEVEL_ROOM_COUNTS = [5, 7, 9, 12, 15]
const MIN_ROOM_DIMENSION = 5
const MAX_ROOM_DIMENSION = 8
const LEVEL_ENEMY_COUNTS = [5, 8, 12, 18, 28]

const EnemyScene = preload("res://enemy.tscn")

class Enemy extends Reference:
	var sprite_node
	var tile
	var full_hp
	var hp
	var dead = false
	
	func _init(game, enemy_level, x, y):
		full_hp = 1 + enemy_level * 2
		hp = full_hp
		tile = Vector2(x, y)
		sprite_node = EnemyScene.instance()
		sprite_node.frame = enemy_level
		sprite_node.position = tile * TILE_SIZE
		game.add_child(sprite_node)
	
	func remove():
		sprite_node.queue_free()
		
	func take_damage(game, dmg):
		if dead:
			return
		
		hp = max(0, hp - dmg)
		sprite_node.get_node("HPBar").rect_size.x = TILE_SIZE * hp / full_hp
		
		if hp == 0:
			dead = true
			game.score += 10 * full_hp
			
var level_num = 0
var map = []
var rooms = []
var level_size
var enemies = []

onready var tile_map = $TileMap
onready var visibility_map = $VisibilityMap
onready var player = $player
onready var walls = tile_map.tile_set.find_tile_by_name("walls")
onready var stone_tile = tile_map.tile_set.find_tile_by_name("stone")
onready var ladder = tile_map.tile_set.find_tile_by_name("ladder")


var player_tile
var score = 0



# Called when the node enters the scene tree for the first time.
func _ready():

	OS.set_window_size(Vector2(1280, 720)) 
	randomize()
	build_level()

func _input(event):
	if !event.is_pressed():
		return
	
	if event.is_action("left"):
		try_move(-1, 0)
	elif event.is_action("right"):
		try_move(1, 0)
	elif event.is_action("up"):
		try_move(0, -1)
	elif event.is_action("down"):
		try_move(0, 1)
		
func try_move(dx, dy):
	var x = player_tile.x + dx
	var y = player_tile.y + dy
	
	var tile_type = stone_tile
	if x>= 0 && x <level_size.x && y >= 0 && y < level_size.y:
		tile_type = map[x][y]
		
	match tile_type:
		walls:
			var blocked = false
			for enemy in enemies:
				if enemy.tile.x == x && enemy.tile.y == y:
					enemy.take_damage(self, 1)
					if enemy.dead:
						enemy.remove()
						enemies.erase(enemy)
					blocked = true
					break
			if !blocked:
				player_tile = Vector2(x, y)
		ladder:
			level_num += 1
			score += 20
			if level_num < LEVEL_SIZES.size():
				build_level()
				call_deferred("update_visuals")
			else:
				score += 1000
				$CanvasLayer/win.visible = true
			
	call_deferred("update_visuals")

func build_level():
	# Start with a blank map
	rooms.clear()
	map.clear()
	tile_map.clear()
	
	level_size = LEVEL_SIZES[level_num]
	for x in range(level_size.x):
		map.append([])
		for y in range(level_size.y):
			map[x].append(stone_tile)
			tile_map.set_cell(x, y, stone_tile)
			visibility_map.set_cell(x, y, 0)
			
	var free_region = [Rect2(Vector2(2, 2), level_size - Vector2(4, 4))]
	var num_rooms = LEVEL_ROOM_COUNTS[level_num]
	for i in range(num_rooms):
		add_room(free_region)
		if free_region.empty():
			break
			
	connect_rooms()
	tile_map.update_bitmask_region()
	
	# Place player
	
	var start_room = rooms.front()
	var player_x = start_room.position.x + 1 + randi() % int(start_room.size.x - 2)
	var player_y = start_room.position.y + 1 + randi() % int(start_room.size.y - 2)
	player_tile = Vector2(player_x, player_y)
	yield(get_tree().create_timer(.2), "timeout")
	call_deferred("update_visuals")
	
	
	# Place enemies
	
	var num_enemies = LEVEL_ENEMY_COUNTS[level_num]
	for i in range(num_enemies):
		var room = rooms[1 + randi() % (rooms.size() - 1)]
		var x = room.position.x + 1 + randi() % int(room.size.x - 2)
		var y = room.position.y + 1 + randi() % int(room.size.y - 2)
		
		var blocked = false
		for enemy in enemies:
			if enemy.tile.x == x && enemy.tile.y == y:
				blocked = true 
				break
		
		if !blocked:
			var enemy = Enemy.new(self, randi() % 2, x, y)
			enemies.append(enemy)
		
	# Place end ladder(hole)
	
	var end_room = rooms.back()
	var ladder_x = end_room.position.x + 1 + randi() % int(end_room.size.x - 2)
	var ladder_y = end_room.position.y + 1 + randi() % int(end_room.size.y - 2)
	set_tile(ladder_x, ladder_y, ladder)
	
	$CanvasLayer/Level.text = "Level: " + str(level_num)
	
func update_visuals():
	player.position = player_tile * TILE_SIZE
	var player_center = tile_to_pixel_center(player_tile.x, player_tile.y)
	var space_state = get_world_2d().direct_space_state
	for x in range(level_size.x):
		for y in range(level_size.y):
			if visibility_map.get_cell(x,y) == 0:
				var x_dir = 1 if x < player_tile.x else -1
				var y_dir = 1 if y < player_tile.y else -1
				var test_point = tile_to_pixel_center(x, y) + Vector2(x_dir, y_dir) * TILE_SIZE / 2
				
				var occlusion = space_state.intersect_ray(player_center, test_point)
				if !occlusion || (occlusion.position - test_point).length() < 1:
					visibility_map.set_cell(x, y, -1)
	$CanvasLayer/Score.text = "Score: " + str(score)

func tile_to_pixel_center(x, y):
	return Vector2((x + 0.5) * TILE_SIZE, (y + 0.5) * TILE_SIZE)
	
func add_room(free_regions):
	var region = free_regions[randi() % free_regions.size()]
	
	var size_x = MIN_ROOM_DIMENSION
	if region.size.x > MIN_ROOM_DIMENSION:
		size_x += randi() % int(region.size.x - MIN_ROOM_DIMENSION)
		
	var size_y = MIN_ROOM_DIMENSION
	if region.size.y > MIN_ROOM_DIMENSION:
		size_y += randi() % int(region.size.y - MIN_ROOM_DIMENSION)
	
	size_x = min(size_x, MAX_ROOM_DIMENSION)
	size_y = min(size_y, MAX_ROOM_DIMENSION)
	
	var start_x = region.position.x
	if region.size.x > size_x:
		start_x += randi() % int(region.size.x - size_x)
		
	var start_y = region.position.y
	if region.size.y > size_y:
		start_y += randi() % int(region.size.y - size_y)
		
	var room = Rect2(start_x, start_y, size_x, size_y)
	rooms.append(room)
	
	# Draw room
	for x in range(start_x, start_x + size_x):
		for y in range(start_y, start_y + size_y):
			set_tile(x, y, walls)
			
	cut_regions(free_regions, room)
	
func cut_regions(free_regions, region_to_remove):
	var removal_queue = []
	var addition_queue = []
	
	for region in free_regions:
		if region.intersects(region_to_remove):
			removal_queue.append(region)
			
			var leftover_left = region_to_remove.position.x - region.position.x - 1
			var leftover_right = region.end.x - region_to_remove.end.x - 1
			var leftover_above = region_to_remove.position.y - region.position.y - 1
			var leftover_below = region.end.y - region_to_remove.end.y - 1
			
			if leftover_left >=MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(region.position, Vector2(leftover_left, region.size.y)))
			if leftover_right >=MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(Vector2(region_to_remove.end.x + 1, region.position.y), Vector2(leftover_right, region.size.y)))
			if leftover_above >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(region.position, Vector2(region.size.x, leftover_above)))
			if leftover_below >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(Vector2(region.position.x, region_to_remove.end.y + 1), Vector2(region.size.x, leftover_below)))			

	for region in removal_queue:
		free_regions.erase(region)
		
	for region in addition_queue:
		free_regions.append(region)
		

func connect_rooms():
	# Build Astar graph of area where corridors can go
	
	var stone_graph = AStar.new()
	var point_id = 0
	for x in range(level_size.x):
		for y in range(level_size.y):
			if map[x][y] == stone_tile:
				stone_graph.add_point(point_id, Vector3(x, y, 0))
				
				# Connect to left if stone
				if x > 0 && map[x - 1][y] == stone_tile:
					var left_point = stone_graph.get_closest_point(Vector3(x - 1, y, 0))
					stone_graph.connect_points(point_id, left_point)
				
				# Connect to above if stone
				if y > 0 && map[x][y - 1] == stone_tile:
					var above_point = stone_graph.get_closest_point(Vector3(x, y - 1, 0))
					stone_graph.connect_points(point_id, above_point)
				
				point_id += 1
				
	# Build AStar graph of room connections
	
	var room_graph = AStar.new()
	point_id = 0
	for room in rooms:
		var room_center = room.position + room.size / 2
		room_graph.add_point(point_id, Vector3(room_center.x, room_center.y, 0))
		point_id += 1
		
	# Add random connections until everything is connected
	
	while !is_everything_connected(room_graph):
		add_random_connection(stone_graph, room_graph)

func is_everything_connected(graph):
	var points = graph.get_points()
	var start = points.pop_back()
	for point in points:
		var path = graph.get_point_path(start, point)
		if !path:
			return false
	return true
	
func add_random_connection(stone_graph, room_graph):
	# Pick rooms to connect
	
	var start_room_id = get_least_connected_point(room_graph)
	var end_room_id = get_nearest_unconnected_point(room_graph, start_room_id)
	
	# Pick door locations
	
	var start_position = pick_random_door_location(rooms[start_room_id])
	var end_position = pick_random_door_location(rooms[end_room_id])
	
	# Find a pth to connect the doors to each other
	
	var closest_start_point = stone_graph.get_closest_point(start_position)
	var closest_end_point = stone_graph.get_closest_point(end_position)
	
	var path = stone_graph.get_point_path(closest_start_point, closest_end_point)
	var stone_points = stone_graph.get_points()
	assert(path)
	
	# Add path to map
	
	path = Array(path)
	
	set_tile(start_position.x, start_position.y, walls)
	set_tile(end_position.x, end_position.y, walls)
	
	for position in path:
		set_tile(position.x, position.y, walls)
		
	room_graph.connect_points(start_room_id, end_room_id)

func get_least_connected_point(graph):
	var point_ids = graph.get_points()
	
	var least
	var tied_for_least = []
	
	for point in point_ids:
		var count = graph.get_point_connections(point).size()
		if !least || count < least:
			least = count
			tied_for_least = [point]
		elif count == least:
			tied_for_least.append(point)
	
	return tied_for_least[randi() % tied_for_least.size()]
	
func get_nearest_unconnected_point(graph, target_point):
	var target_position = graph.get_point_position(target_point)
	var point_ids = graph.get_points()
	
	var nearest
	var tied_for_nearest = []
	
	for point in point_ids:
		# Skip the same point
		if point == target_point:
			continue
		
		# Also skip if there is already a connecting path
		var path = graph.get_point_path(point, target_point)
		if path:
			continue
		
		var dist = (graph.get_point_position(point) - target_position).length()
		if !nearest || dist < nearest:
			nearest = dist
			tied_for_nearest = [point]
		elif dist == nearest:
			tied_for_nearest.append(point)
			
		return tied_for_nearest[randi() % tied_for_nearest.size()]
		
func pick_random_door_location(room):
	var options = []
	
	# Top and bottom walls
	for x in range(room.position.x + 1, room.end.x - 2):
		options.append(Vector3(x, room.position.y, 0))
		options.append(Vector3(x, room.end.y - 1, 0))

	# Left and right walls
	for y in range(room.position.y + 1, room.end.y - 2):
		options.append(Vector3(room.position.x, y, 0))
		options.append(Vector3(room.end.x - 1, y, 0))
		

	
	return options[randi() % options.size()]
		
	
func set_tile(x, y, type):
	map[x][y] = type
	tile_map.set_cell(x, y, type)
				


func _on_Button_pressed():
	level_num = 0 
	build_level()
	$CanvasLayer/win.visible = false
