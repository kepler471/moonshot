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
var damaged_tiles = {}
var damage_tile_references = {2: 22, 4: 23, 6: 24, 8: 21}
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
	
func damage_breakable_tile(tileset: TileMap, breakable_tileset: TileMap, position):
	var damage
	var tile = tileset.get_cellv(position)
	var breakable_tile = breakable_tileset.get_cellv(position)
	# Return if there isn't a breakable tile at the position
	if breakable_tileset.get_cellv(position) == -1:
		return
		
	# Get existing damage
	if not damaged_tiles.has(position):
		damage = 2
		damaged_tiles[position] = 0
	else:
		damage = damaged_tiles[position] + 2
		
	# If at max damage then remove the tile from the main tileset
	if damage == 8:
		tileset.set_cellv(position, -1)
		breakable_tileset.set_cellv(position, -1)
		tileset.update_bitmask_region()
	else:
		breakable_tileset.set_cellv(position, damage_tile_references[damage])
	
	# Increase the damageat the position
	damaged_tiles[position] += 2
	
		
	
