extends Node2D

const floor_Generator = preload("res://procedural_map_generation/floor_generator.gd")

func _ready():
	var gen = floor_Generator.new(1)
	gen.complete_Level()
	var a = gen.map
	print_map(gen.map.duplicate())
	
# Still having issues with this, for some reason its not reconising the 
# dictionarykeys, although the dictionaryisbuilding ok 
func print_map(map:Dictionary):
	#print map
	#(0,0) is in the top left
	var lines = []
	# Calculate the maximum x-dimension and y-dimension of the map dictionary
	var size_x = map.keys().max() - map.keys().min()
	var min_x = map.keys().min()
	var potential_size_y = []
	var potential_min_y = []
	for key in map.keys():
		potential_size_y.append(map[key].keys().max() - map[key].keys().min())
		potential_min_y.append(map[key].keys().min())
	var size_y = potential_size_y.max()
	var min_y = potential_min_y.min()
	
	for x in range(size_x):
		lines.append("")
	for x in range(min_x, min_x + size_x, 1):
		for y in range(min_y, min_y + size_y, 1):
			var a = map.keys()
			var b = map[0].keys()
			if(map.has(float(x)) && map[x].has(float(y))):
				lines[y] += map[float(x)][float(y)].room_Type
			else:
				lines[y] += "-"
	for x in range(lines.size()):
		print(lines[x])
