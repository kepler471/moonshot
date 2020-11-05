extends Node2D

const LG = preload("res://Scripts/Floor_Generator.gd")

var l = LG.new(1)

func _ready():
	print(l.max_Rooms)
	l.resize_Map(4,4)
	for i in range(4):
		for j in range(4):
			l.map[i][j] = max(i,j)
	map_print(l.map)
	
func map_print (map):
	var line : String
	for i in range(map[0].size()):
		line = ""
		for j in range(map.size()):
			line += (map[j][i]) as String
		print(line)
