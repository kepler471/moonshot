extends Node2D

var node_Types:Dictionary = {}
const distance = 100
var gen
var draw_map
var minimap

	
func _init(level_no):
	gen = preload("res://procedural_map_generation/floor_generator.gd").new(level_no)
	draw_map = preload("res://procedural_map_generation/draw_map.gd")
	
	
	gen.complete_Level()
	var level_map = gen.map
	minimap = draw_map.new(gen)
	return [gen, minimap]
	

	
