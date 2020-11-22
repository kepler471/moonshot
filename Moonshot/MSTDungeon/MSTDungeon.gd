# Generates a dungeon using RigidBody2D physics and Minimum Spanning Tree (MST).
#
# The algorithm works like so:
#
# 1. Spawns and spreads collision shapes around the game world using the physics engine.
# 2. Waits for the rooms to be in a more or less resting state.
# 3. Selects some main rooms for the level based on the average room size.
# 4. Creates a Minimum Spanning Tree graph that connects the rooms.
# 5. Adds back some connections after calculating the MST so the player doesn't need to backtrack.
tool
extends Node2D

# Emitted when all the rooms stabilized.
signal rooms_placed

const Room := preload("Room.tscn")
const exit_hori = preload("res://room_templates/exit_hori.tscn")
const exit_vert = preload("res://room_templates/exit_vert.tscn")
var baddy = preload("res://baddies/BearBoi.tscn")

# Maximum number of generated rooms.
export var max_rooms := 60
# Controls the number of paths we add to the dungeon after generating it,
# limiting player backtracking.
export var reconnection_factor := 0.025
# This allows running code in the editor
export(bool) var redraw setget redraw

var _rng := RandomNumberGenerator.new()
var _data := {}
var _path: AStar2D = null
var _sleeping_rooms := 0
var _mean_room_size := Vector2.ZERO
var _draw_extra := []

#onready var rooms: Node2D = $Rooms
onready var level: TileMap = $Level
var rooms
var camera
var player

var file = File.new()




func redraw(value = null):
	print("redraw scene")
	set_process(true)
	_rng = RandomNumberGenerator.new()
	_data = {}
	_path = null
	_sleeping_rooms = 0
	_mean_room_size = Vector2.ZERO
	_draw_extra = []
	_rng.randomize()
	_generate()



func _input(event):
	if event.is_action_pressed("ui_accept"):
		for i in range(100):
			player.queue_free()
			redraw()
			_save_data()

	if event.is_action_pressed("ui_end"):
		_save_data()

	if event.is_action_pressed("ui_home"):
		player.queue_free()
		redraw()

	if event.is_action_pressed("ui_page_up"):
		camera.zoom += Vector2(1,1)
	if event.is_action_pressed("ui_page_down"):
		camera.zoom = Vector2(1,1)


func _save_data():
	var filename = "res://MSTDungeon/room_"+String(_rng.get_seed())+".tscn"
	print("saving ::: ", filename)
	var packed_scene = PackedScene.new()
	packed_scene.pack(get_tree().get_current_scene())
	ResourceSaver.save(filename, packed_scene)


func _ready() -> void:
	if Engine.is_editor_hint(): return
	# TODO: run a loop of redraws, save the _data, save the scene or tilemap node if possible, without player and with all exits, or from base canvas
	set_process(true)
	_rng.randomize()
	_generate()


# Calld every time stabilizes (mode changes to RigidBody2D.MODE_STATIC).
#
# Once all rooms have stabilized it calcualtes a playable dungeon `_path` using the MST
# algorithm. Based on the calculated `_path`, it populates `_data` with room and corridor tile
# positions.
#
# It emits the "rooms_placed" signal when it finishes so we can begin the tileset placement.
func _on_Room_sleeping_state_changed(room: MSTDungeonRoom) -> void:
	room.modulate = Color.yellow
	_sleeping_rooms += 1
	if _sleeping_rooms < max_rooms:
		return

	var main_rooms := []
	var main_rooms_positions := []
	for room in rooms.get_children():
		if _is_main_room(room):
			main_rooms.push_back(room)
			main_rooms_positions.push_back(room.position)
			room.modulate = Color.red

	_path = MSTDungeonUtils.mst(main_rooms_positions)

	update()
	yield(get_tree().create_timer(1), "timeout")

	for point1_id in _path.get_points():
		for point2_id in _path.get_points():
			if (
				point1_id != point2_id
				and not _path.are_points_connected(point1_id, point2_id)
				and _rng.randf() < reconnection_factor
			):
				_path.connect_points(point1_id, point2_id)
				_draw_extra.push_back(
					[_path.get_point_position(point1_id), _path.get_point_position(point2_id)]
				)

	update()

	for room in main_rooms:
		_add_room(room)
	_add_corridors()

	set_process(false)
	emit_signal("rooms_placed")


# This is for visual feedback. We just re-render the rooms every frame.
func _process(delta: float) -> void:
	level.clear()
	for room in rooms.get_children():
		for offset in room:
			level.set_cellv(offset, 0)


# Places the rooms and starts the physics simulation. Once the simulation is done
# ("rooms_placed" gets emitted), it continues by assigning tiles in the Level node.
func _generate() -> void:
	if rooms != null: rooms.queue_free()
	rooms = Node2D.new()
	rooms.name = "Rooms"
	add_child(rooms)

	for _i in range(max_rooms):
		# Generate `max_rooms` rooms and set them up
		var room := Room.instance()
		room.connect("sleeping_state_changed", self, "_on_Room_sleeping_state_changed", [room])
		room.setup(_rng, level)
		rooms.add_child(room)

		_mean_room_size += room.size
	_mean_room_size /= rooms.get_child_count()

	# Wait for all rooms to be positioned in the game world.
	yield(self, "rooms_placed")

	rooms.hide()
	rooms.queue_free()

	print(len(_path.get_points()), " points total.")
	print("East  ::: ", _path.get_closest_point(Vector2(-5000,0)), " ::: ", _path.get_point_position(_path.get_closest_point(Vector2(-5000,0))))
	print("North ::: ", _path.get_closest_point(Vector2(0,-5000)), " ::: ", _path.get_point_position(_path.get_closest_point(Vector2(0,-5000))))
	print("South ::: ", _path.get_closest_point(Vector2(0,5000)), " ::: ", _path.get_point_position(_path.get_closest_point(Vector2(0,5000))))
	print("West  ::: ", _path.get_closest_point(Vector2(5000,0)), " ::: ", _path.get_point_position(_path.get_closest_point(Vector2(5000,0))))

	var east  = _path.get_point_position(_path.get_closest_point(Vector2(-5000,0)))
	var north = _path.get_point_position(_path.get_closest_point(Vector2(0,-5000)))
	var south = _path.get_point_position(_path.get_closest_point(Vector2(0, 5000)))
	var west  = _path.get_point_position(_path.get_closest_point(Vector2(5000, 0)))

	print(exit_hori.instance().position.x)
#	exit_hori.instance().position = north
#	exit_vert.instance().position = east
#	exit_vert.instance().position = west

	print("world north::: ", level.world_to_map(north))
	print("world south::: ", level.world_to_map(south))
	print("world east ::: ", level.world_to_map(east))
	print("world west ::: ", level.world_to_map(west))

	print(level.get_used_cells())
	var rect = level.get_used_rect()
	print("box end check ::: ", rect.end)
	print("box pos check ::: ", rect.position)
	print("box siz check ::: ", rect.size)
	level.clear()

	for i in range(rect.size.x):
		for j in range(rect.size.y):
			var X = i+rect.position.x - 1
			var Y = j+rect.position.y
			level.set_cell(X, Y, 4)

	for i in _data:
		level.set_cell(i.x, i.y, -1)

	level.update_bitmask_region()
	print(level.get_used_cells())
	Utils.reset_player()
	player = Utils.Player
	add_child(player)
	Utils.Player.position = north
	camera = Utils.Player.get_node("Camera2D")
	camera.current = true



# Adds room tile positions to `_data`.
func _add_room(room: MSTDungeonRoom) -> void:
	for offset in room:
		_data[offset] = null


# Adds both secondary room and corridor tile positions to `_data`. Secondary rooms are the ones
# intersecting the corridors.
func _add_corridors():
	# Stores existing connections in its keys.
	var connected := {}

	# Checks if points are connected by a corridor. If not, adds a corridor.
	for point1_id in _path.get_points():
		for point2_id in _path.get_point_connections(point1_id):
			var point1 := _path.get_point_position(point1_id)
			var point2 := _path.get_point_position(point2_id)
			if Vector2(point1_id, point2_id) in connected:
				continue

			point1 = level.world_to_map(point1)
			point2 = level.world_to_map(point2)
			_add_corridor(point1.x, point2.x, point1.y, Vector2.AXIS_X)
			_add_corridor(point1.y, point2.y, point2.x, Vector2.AXIS_Y)

			# Stores the connection between point 1 and 2.
			connected[Vector2(point1_id, point2_id)] = null
			connected[Vector2(point2_id, point1_id)] = null

# Adds a specific corridor (defined by the input parameters) to `_data`. It also adds all
# secondary rooms intersecting the corridor path.
func _add_corridor(start: int, end: int, constant: int, axis: int) -> void:
	var t := min(start, end)
	while t <= max(start, end):
		var point := Vector2.ZERO
		match axis:
			Vector2.AXIS_X:
				point = Vector2(t, constant)
			Vector2.AXIS_Y:
				point = Vector2(constant, t)

		t += 1
		for room in rooms.get_children():
			if _is_main_room(room):
				continue

			var top_left: Vector2 = level.world_to_map(room.position) - room.size / 2
			var bottom_right: Vector2 = level.world_to_map(room.position) + room.size / 2
			if (
				top_left.x <= point.x
				and point.x < bottom_right.x
				and top_left.y <= point.y
				and point.y < bottom_right.y
			):
				_add_room(room)
				t = bottom_right[axis]
		_data[point] = null


func _is_main_room(room: MSTDungeonRoom) -> bool:
	return room.size.x > _mean_room_size.x and room.size.y > _mean_room_size.y
