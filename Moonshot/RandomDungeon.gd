extends Reference

class_name RandomDungeon

var x_size = 60
var y_size = 40
var rng = RandomNumberGenerator.new()
var min_room_size = 5
var max_room_size = 15
var num_rooms = 0
var min_rooms = 10
var max_rooms = 15
var map = []
var rooms = []
var first_room = {}
var last_room = {}
var end = {}
var start = {}
var connected = []
var light = 0


func generate(world : Node):

	# build out the initial 2d array
	for y in range(self.y_size):
		# initialize each row
		self.map.append([])
		for x in range(self.x_size):
			self.map[y].append({})
			self.map[y][x]['t'] = 0
			self.map[y][x]['path'] = false
			self.map[y][x]['pos'] = {
				'x': x,
				'y': y
			}
			if self.light == 0:
				self.map[y][x]['r'] = 1
			else:
				self.map[y][x] = 0
	self.num_rooms = get_random_int(self.min_rooms, self.max_rooms)
	var i = 0
	while i < self.num_rooms:
		var room = {}
		room['x'] = get_random_int(1, (self.x_size - self.max_room_size - 1))
		room['y'] = get_random_int(1, (self.y_size - self.max_room_size - 1))
		room['w'] = get_random_int(self.min_room_size, self.max_room_size)
		room['h'] = get_random_int(self.min_room_size, self.max_room_size)
		room['c'] = false
		if does_collide(room):
			continue
		room['w'] -= 1
		room['h'] -= 1
		self.rooms.append(room)
		i += 1
	shrink_map(0)
	for k in range(len(self.rooms)):
		var room = self.rooms[k]
		var closest_room = find_closest(room, self.connected)
		if closest_room.empty():
			break
		connect_rooms(room, closest_room, true)
	for k in range(len(self.rooms)):
		var room = self.rooms[k]
		for y in range(room['y'], room['y'] + room['h']):
			for x in range(room['x'], room['x'] + room['w']):
				self.map[y][x]['t'] = 1
	# this part builds the walls
	for y in range(self.y_size):
		for x in range(self.x_size):
			if self.map[y][x]['t'] == 1:
				var yy = y - 1
				while yy <= y + 1:
					var xx = x - 1
					while xx <= x+1:
						if self.map[yy][xx]['t'] == 0:
							self.map[yy][xx]['t'] = 2
						xx += 2
					yy += 2

	find_farthest()
	mark_start_and_end()
	place_geometry(world)

func does_collide(room):
	for i in range(len(self.rooms)):
		var comparison_room = self.rooms[i]
		if room == comparison_room:
			continue
		if room['x'] < comparison_room['x'] + comparison_room['w'] \
				and room['x'] + room['w'] > comparison_room['x'] \
				and room['y'] < comparison_room['y'] + comparison_room['h'] \
				and room['y'] + room['h'] > comparison_room['y']:
			return true
	return false

func point_collide(x, y):
	if self.map[x][y]['t'] == 1:
		return false
	return true

func shrink_map(shrink_limit):
	for value in range(shrink_limit):
		for i in range(len(self.rooms)):
			var room = self.rooms[i]
			if room['x'] > 1:
				room['x'] -= 1
			if room['y'] > 1:
				room['y'] -= 1
			if self.does_collide(room):
				if room['x'] > 1:
					room['x'] += 1
				if room['y'] > 1:
					room['y'] += 1
				continue

func find_closest(room, others=null):
	var master_room = {'x': room['x'] + room['w'] / 2,
				   'y': room['y'] + room['h'] / 2
				   }
	var room_min = 1000
	var final_room = {}
	for i in range(len(self.rooms)):
		var comparison_room = self.rooms[i]
		if room == comparison_room:
			continue
		if not others.empty():
			var is_closest = false
			for j in range(len(others)):
				if comparison_room == others[j]:
					is_closest = true
					break
			if is_closest:
				continue
		var room_avg = {
			'x': comparison_room['x'] + comparison_room['w'] / 2,
			'y': comparison_room['y'] + comparison_room['h'] / 2
		}
		var room_calc = abs(room_avg['x'] - master_room['x']) + abs(room_avg['y'] - master_room['y'])
		if room_calc < room_min:
			room_min = room_calc
			final_room = comparison_room
	return final_room

func find_farthest():
	var room_pair = []
	var swap_room = 0
	for i in range(len(self.rooms)):
		var room = self.rooms[i]
		var midA = {
			'x': room['x'] + room['w'] / 2,
			'y': room['y'] + room['h'] / 2
		}
		for j in range(len(self.rooms)):
			if i == j:
				continue
			var closest_room = self.rooms[j]
			var midB = {
				'x': closest_room['x'] + closest_room['w'] / 2,
				'y': closest_room['y'] + closest_room['h'] /2
			}
			var math_room = abs(midB['x'] - midA['x']) + abs(midB['y'] - midA['y'])
			if math_room > swap_room:
				swap_room = math_room
				room_pair = [room, closest_room]
	self.first_room = room_pair[0]
	self.last_room = room_pair[1]

func connect_rooms(room, closest_room, good):
	var path_part_1 = {
		'x': get_random_int(room['x'], room['x'] + room['w']),
		'y': get_random_int(room['y'], room['y'] + room['h'])
	}
	var path_part_2 = {
		'x': get_random_int(closest_room['x'], closest_room['x'] + closest_room['w']),
		'y': get_random_int(closest_room['y'], closest_room['y'] + closest_room['h'])
	}
	while path_part_1['x'] != path_part_2['x'] or path_part_1['y'] != path_part_2['y']:
		if path_part_1["x"] != path_part_2["x"]:
			if path_part_2["x"] < path_part_1["x"]:
				path_part_2["x"] += 1
			else:
				path_part_2["x"] -= 1
		else:
			if path_part_1["y"] != path_part_2["y"]:
				if path_part_2["y"] < path_part_1["y"]:
					path_part_2["y"] += 1
				else:
					path_part_2["y"] -= 1

		self.map[path_part_2['y']][path_part_2['x']]['t'] = 1
	if good:
		room['c'] = true
		closest_room['c'] = true
		self.connected.append(room)

func mark_start_and_end():
	self.end = {
		'pos': {
			'x': get_random_int(self.first_room['x'] + 1, self.first_room['x'] + self.first_room['w'] - 1),
			'y': get_random_int(self.first_room['y'] + 1, self.first_room['y'] + self.first_room['h'] - 1)
		}
	}
	self.start = {
		'pos': {
			'x': get_random_int(self.last_room['x'] + 1, self.last_room['x'] + self.last_room['w'] - 1),
			'y': get_random_int(self.last_room['y'] + 1, self.last_room['y'] + self.last_room['h'] - 1)
		}
	}
	self.map[self.end["pos"]["y"]][self.end["pos"]["x"]]["t"] = 3
	self.map[self.start["pos"]["y"]][self.start["pos"]["x"]]["t"] = 4

func place_geometry(world : Node):
	var yy = 0
	for y in range(self.y_size):
		var xx = 0
		for x in range(self.x_size):
			if self.map[y][x]['t'] == 0 or self.map[y][x]['r'] == 0:  # these are not part of the maze body
				pass
			elif self.map[y][x]['t'] == 2:
				# these are the walls
#				bpy.ops.mesh.primitive_cube_add(size=2, enter_editmode=false, location=(xx, yy, 0))
				var cube = StaticBody.new()
				var coll = CollisionShape.new()
				var mesh = MeshInstance.new()
				var material = SpatialMaterial.new()
				
				cube.transform.origin = Vector3(xx, 0, yy)
				world.add_child(cube)
				coll.shape = BoxShape.new()
				cube.add_child(coll)
				mesh.mesh = CubeMesh.new()
				material.albedo_color = Color(randf(), randf(), randf())
				mesh.set_surface_material(0, material)
				cube.add_child(mesh)
			elif self.map[y][x]['t'] == 3:
				pass
#				# this is the beginning
#				bpy.ops.mesh.primitive_uv_sphere_add(radius=1, enter_editmode=false, location=(xx, yy, 0))
			elif self.map[y][x]['t'] == 4:
				pass
#				# this is the end
#				bpy.ops.mesh.primitive_cylinder_add(radius=1, enter_editmode=false, location=(xx, yy, 0))
			else:
				var cube = StaticBody.new()
				var coll = CollisionShape.new()
				var mesh = MeshInstance.new()
				var material = SpatialMaterial.new()
				
				cube.transform.origin = Vector3(xx, -2, yy)
				world.add_child(cube)
				coll.shape = BoxShape.new()
				cube.add_child(coll)
				mesh.mesh = CubeMesh.new()
				material.albedo_color = Color(0.7, 0.5, 0.3)
				mesh.set_surface_material(0, material)
				cube.add_child(mesh)
				# these are the floor tiles,
#				bpy.ops.mesh.primitive_plane_add(size=2, enter_editmode=false, location=(xx, yy, -1))
			xx += 2
		yy += 2


func get_random_int(low, high):
	self.rng.randomize()
	return self.rng.randi_range(low, high - 1)



## joins all separate cube into a single object,
## deletes inner faces to make the object hollow
#def cleanup_mesh():
#	# get all the cubes selected
#	bpy.ops.object.select_all(action='TOGGLE')
#	bpy.ops.object.select_all(action='TOGGLE')
#	# join all of the separate cube objects into one
#	bpy.ops.object.join()
#	# jump into edit mode
#	bpy.ops.object.mode_set(mode='EDIT')
#	# get save the mesh data into a variable
#	mesh = bmesh.from_edit_mesh(bpy.context.object.data)
#	# select the entire mesh
#	bpy.ops.mesh.select_all(action='SELECT')
#	# remove overlapping verts
#	bpy.ops.mesh.remove_doubles()
#	# de-select everything in edit mode
#	bpy.ops.mesh.select_all(action='DESELECT')
#	# get back out of edit mode
#	bpy.ops.object.mode_set(mode='OBJECT')
#
#
## delete everything in the scene
#def clear_scene():
#	if bpy.context.active_object:
#		if bpy.context.active_object.mode != 'OBJECT':
#			bpy.ops.object.mode_set(mode='OBJECT')
#	bpy.ops.object.select_all(action='SELECT')
#	bpy.ops.object.delete(use_global=false)
#
#
#if __name__ == '__main__':
#	clear_scene()
#	dungeon = Dungeon()
#	dungeon.generate()
#	cleanup_mesh()
