extends Reference


const distance = Vector2(25, 25)
var minimap_index = {}
var minimap_node = Node2D.new()
var start_pos = Vector2.ZERO
var curr_pos
var opens = []
var done = []
# minimap connections indexed by the rooms they connect to toggle visibility
var indexed_connections = {}
var world_map
var current_location_type_scene = preload("res://procedural_map_generation/assets/CurrentLocation.tscn")
var connection_type_scene = preload("res://procedural_map_generation/assets/Connection.tscn")
var debug = true

func _init(gen):
	world_map = gen.map
	opens.append(start_pos)
	
	while opens.size():
		curr_pos = opens.pop_front()
		add_node_at(curr_pos)
		var connected = gen.get_Connected_Vectors(curr_pos)
		for c in connected:
			if !done.has(c):
				add_connection_between(curr_pos, c)
				opens.append(c)
		done.append(curr_pos)
	
	# Set the minimap index (0, 0) to be thecurrent location node
	minimap_index[start_pos].queue_free()
	minimap_index[start_pos] = current_location_type_scene.instance()
	turn_on_visibility(start_pos)
	
	minimap_node.add_child(minimap_index[start_pos])
	return [minimap_node, minimap_index]
	

func add_node_at (pos:Vector2):
	var this_node = world_map[pos].get_type_scene().instance()
	this_node.set_position(Vector2(pos.x*distance[0], pos.y*distance[1]))
	this_node.visible = false
	minimap_index[pos] = this_node
	minimap_node.add_child(this_node)
	
	
func change_current_node(new_pos: Vector2, old_pos:Vector2):
	if debug:
		print("Removing minimap node at " + str(old_pos))
	minimap_node.remove_child(minimap_index[old_pos])
	minimap_index[old_pos].queue_free()
	if debug:
		print("setting minimap node " + str(old_pos) + " to " + world_map[old_pos].get_room_type())
	minimap_index[old_pos] = world_map[old_pos].get_type_scene().instance()
	minimap_index[old_pos].set_position(Vector2(old_pos.x*distance[0], old_pos.y*distance[1]))
	minimap_node.add_child(minimap_index[old_pos])
	
	if debug:
		print("Removing minimap node at " + str(new_pos))
extends Reference


const distance = Vector2(25, 25)
var minimap_index = {}
var minimap_node = Node2D.new()
var start_pos = Vector2.ZERO
var curr_pos
var opens = []
var done = []
var world_map
var current_location_type_scene = preload("res://procedural_map_generation/assets/CurrentLocation.tscn")
var connection_type_scene = preload("res://procedural_map_generation/assets/Connection.tscn")
var debug = true

func _init(gen):
	world_map = gen.map
	opens.append(start_pos)
	
	while opens.size():
		curr_pos = opens.pop_front()
		add_node_at(curr_pos)
		var connected = gen.get_Connected_Vectors(curr_pos)
		for c in connected:
			if !done.has(c):
				add_connection_between(curr_pos, c)
				opens.append(c)
		done.append(curr_pos)
	
	# Set the minimap index (0, 0) to be thecurrent location node
	minimap_index[start_pos].queue_free()
	minimap_index[start_pos] = current_location_type_scene.instance()
	minimap_node.add_child(minimap_index[start_pos])
	return [minimap_node, minimap_index]
	

func add_node_at (pos:Vector2):
	var this_node = world_map[pos].get_type_scene().instance()
	this_node.set_position(Vector2(pos.x*distance[0], pos.y*distance[1]))
	minimap_index[pos] = this_node
	minimap_node.add_child(this_node)
	
	
func change_current_node(new_pos: Vector2, old_pos:Vector2):
	if debug:
		print("Removing minimap node at " + str(old_pos))
	minimap_node.remove_child(minimap_index[old_pos])
	minimap_index[old_pos].queue_free()
	if debug:
		print("setting minimap node " + str(old_pos) + " to " + world_map[old_pos].get_room_type())
	minimap_index[old_pos] = world_map[old_pos].get_type_scene().instance()
	minimap_index[old_pos].set_position(Vector2(old_pos.x*distance[0], old_pos.y*distance[1]))
	minimap_node.add_child(minimap_index[old_pos])
	
	if debug:
		print("Removing minimap node at " + str(new_pos))
	minimap_node.remove_child(minimap_index[new_pos])
	minimap_index[new_pos].queue_free()
	minimap_index[new_pos] = 	current_location_type_scene.instance()
	if debug:
		print("setting minimap node " + str(new_pos) + " to CurrentLocation")
	minimap_index[new_pos].set_position(Vector2(new_pos.x*distance[0], new_pos.y*distance[1]))
	minimap_node.add_child(minimap_index[new_pos])

	
func add_connection_between (pos1:Vector2, pos2:Vector2):
	var avg:Vector2 = (pos1 + pos2)/2
	var diff = pos2 - pos1
	var angle
	if(diff.y == 0):
		angle = 0
	elif(diff.x == 0):
		angle = PI/2
	else:
		angle = atan(diff.x/diff.y)
		
	var this_conn = connection_type_scene.instance()
	this_conn.set_position(avg * distance)
	this_conn.set_rotation(angle)
	minimap_node.add_child(this_conn)
