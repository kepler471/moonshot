extends Reference

class_name RandomWalk

# Controls the distances that are moved
var X_MOVE_DISTANCE = 2.0
var Y_MOVE_DISTANCE = 2.0

# Position in space
var x_pos = 0
var y_pos = 0
var z_pos = 0

var ITERATIONS = 1000

var rng = RandomNumberGenerator.new()

func generate_maze(world : Node):
	for _i in range(ITERATIONS):
		var direction = get_random_direction()
		next_move(world, direction)
	# cleanup_mesh()
	
func get_random_direction():
	var direction = {0: "up", 1: "right", 2: "down", 3: "left"}
	# Can toggle rng.randomize() if we want to work from the same
	# 	set of random numbers, which may help with testing.
	rng.randomize()
	var random_num = rng.randi_range(0, 3)
	return direction[random_num]

func next_move(world, direction):
	match direction:
		"up":
			y_pos += Y_MOVE_DISTANCE
			place_cube(world)
			
		"right":
			x_pos += X_MOVE_DISTANCE
			place_cube(world)
			
		"down":
			y_pos -= Y_MOVE_DISTANCE
			place_cube(world)
			
		"left":
			x_pos -= X_MOVE_DISTANCE
			place_cube(world)
		
func place_cube(world : Node):
	var cube = StaticBody.new()
	var coll = CollisionShape.new()
	var mesh = MeshInstance.new()
	var material = SpatialMaterial.new()
	
	cube.transform.origin = Vector3(x_pos, 0, y_pos)
	world.add_child(cube)
	coll.shape = BoxShape.new()
	cube.add_child(coll)
	mesh.mesh = CubeMesh.new()
	material.albedo_color = Color(randf(), randf(), randf())
	mesh.set_surface_material(0, material)
	cube.add_child(mesh)
