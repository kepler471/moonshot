extends Reference


const distance = Vector2(25, 25)
var minimap_index = {}
var minimap_node = Node2D.new()
var start_pos = Vector2.ZERO
var shifted_distance = Vector2.ZERO
var curr_pos
var opens = []
var done = []
# minimap connections indexed by the rooms they connect to toggle visibility
var indexed_connections = {}
var current_not_hidden_nodes = []
var current_not_hidden_conns = []
var world_map
var minimap_size
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
	minimap_index[start_pos].visible = true
	current_not_hidden_nodes.append(start_pos)
	
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
	minimap_node.remove_child(minimap_index[new_pos])
	minimap_index[new_pos].queue_free()
	minimap_index[new_pos] = 	current_location_type_scene.instance()
	if debug:
		print("setting minimap node " + str(new_pos) + " to CurrentLocation")
	minimap_index[new_pos].set_position(Vector2(new_pos.x*distance[0], new_pos.y*distance[1]))
	minimap_node.add_child(minimap_index[new_pos])
	shift_node_positions(old_pos - new_pos)
	turn_on_visibility(new_pos, old_pos)
	set_minimap_visibility()

	
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
	# Start with it invisible
	this_conn.visible = false
	# Add to position indexed list, create the list first if there isn't one at the index
	if not indexed_connections.has(pos1):
		indexed_connections[pos1] = {}
	if not indexed_connections.has(pos2):
		indexed_connections[pos2] = {}
		
	# Index the connections
	indexed_connections[pos1][pos2] = this_conn
	indexed_connections[pos2][pos1] = this_conn

# Set the visibility for the node and the surrounding connections to be true
func turn_on_visibility(new_pos: Vector2, old_pos: Vector2):
	minimap_index[new_pos].visible = true
	current_not_hidden_nodes.append(new_pos)
	indexed_connections[new_pos][old_pos].visible = true
	current_not_hidden_conns.append(indexed_connections[new_pos][old_pos])
	
func shift_node_positions(diff: Vector2):
	var shift_distance = Vector2.ZERO
#	var key_specific
#	var conn_specific
	for key in indexed_connections:
#		key_specific = key
		for conn in indexed_connections[key]:
#			conn_specific = conn
			shift_distance.x = diff.x * distance.x
			shift_distance.y = diff.y * distance.y
			indexed_connections[key][conn].position += shift_distance / 2
	shifted_distance += shift_distance
	for node_vector in minimap_index:
		shift_distance.x = diff.x * distance.x
		shift_distance.y = diff.y * distance.y
		minimap_index[node_vector].position = Vector2(node_vector.x*distance[0], node_vector.y*distance[1]) + shifted_distance
		
		
func set_minimap_size(minimap_size_vector: Vector2):
	minimap_size = minimap_size_vector
	set_minimap_visibility()

# Updates the visibility of all minimap nodes basedontheir position 
func set_minimap_visibility():
	# turn off all nodes first
	for key in indexed_connections:
		for conn in indexed_connections[key]:
			indexed_connections[key][conn].visible = false
	for key in minimap_index:
		minimap_index[key].visible = false
		
	# turn on all nodes within the minimap boundaries
	for conn in current_not_hidden_conns:
		if (abs(conn.position.x) < minimap_size.x) && (abs(conn.position.y) < minimap_size.y):
			conn.visible = true
			
	for node_coord in current_not_hidden_nodes:
		var node = minimap_index[node_coord]
		if (abs(node.position.x) < minimap_size.x) && (abs(node.position.y) < minimap_size.y):
			node.visible = true

