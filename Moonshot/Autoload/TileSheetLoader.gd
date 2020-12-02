extends Node

var tile_path = "res://assets/tile_maps/base_tiles/"

var Blue1 	= load(tile_path + "Blue1.png")
var Blue2 	= load(tile_path + "Blue2.png")
var Grey 	= load(tile_path + "Grey.png")
var Ice 	= load(tile_path + "Ice.png")
var Pink 	= load(tile_path + "Pink.png")
var Purple 	= load(tile_path + "Purple.png")
var Red1 	= load(tile_path + "Red1.png")
var Red2 	= load(tile_path + "Red2.png")
var Teal1 	= load(tile_path + "Teal1.png")
var Teal2 	= load(tile_path + "Teal2.png")
var Yellow1 = load(tile_path + "Yellow1.png")
var Yellow2 = load(tile_path + "Yellow2.png")

var tilesheet_array = [Blue1,Blue2,Grey,Ice,Pink,Purple,Red1,Red2,Teal1,Teal2,Yellow1,Yellow2]
var tilesheet_count = tilesheet_array.size()

var level_no = 0

func _ready():
	randomize()
	tilesheet_array.shuffle()
	
func get_tilesheet():
	if level_no >= tilesheet_count:
		tilesheet_array.shuffle()
		level_no = 0
	return tilesheet_array[level_no]

func update_level_no():
	level_no += 1
	
