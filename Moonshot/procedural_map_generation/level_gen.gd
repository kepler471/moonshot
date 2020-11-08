extends Node2D

const floor_Generator = preload("res://procedural_map_generation/floor_generator.gd")

func _ready():
	var gen = floor_Generator.new(1)
	gen.complete_Level()
	gen.cleanup()
	print_map(gen.map.duplicate())
	
func print_map(map:Array):
	#print map
	#(0,0) is in the top left
	var lines = []
	for x in range(map[0].size()):
		lines.append("")
	for x in range(map.size()):
		for y in range(map[x].size()):
			if(map[x][y]):
				lines[y] += map[x][y].room_Type[0]
			else:
				lines[y] += "-"
	for x in range(lines.size()):
		print(lines[x])
