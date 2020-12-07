extends TileMap

var base_tile_set = load("res://assets/tile_maps/TileSet_v1.tres")
onready var new_tiles = TileSheetLoader.get_tilesheet()

func _ready():
	#what the hell is with these tileset indexes...
	base_tile_set.tile_set_texture(4,new_tiles)
	base_tile_set.tile_set_texture(18,new_tiles)
	base_tile_set.tile_set_texture(20,new_tiles)
	base_tile_set.tile_set_texture(21,new_tiles)
	base_tile_set.tile_set_texture(22,new_tiles)
	base_tile_set.tile_set_texture(23,new_tiles)
	base_tile_set.tile_set_texture(24,new_tiles)
	self.tile_set = base_tile_set
