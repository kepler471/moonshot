extends Spatial

onready var world = get_node(".")
#var myclass = load("RandomWalk.gd")
#const myclass = preload("RandomWalk.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	#var walk = myclass.new()
	#var walk = RandomWalk.new()
#	walk.generate_maze(world)
	
	var dungeon = RandomDungeon.new()
	dungeon.generate(world)
