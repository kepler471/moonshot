extends Node
class_name BaddieBuilder

# public modifyable attributes on a baddie
const attr: Dictionary = {
	"INITIAL_HP": "inital_hp", # float
	"HP": "hp", # float
	"GRAVITY": "gravity", # int
	"SPEED": "speed", # int
	"VELOCITY": "velocity", #  Vector2
	"SHOT_SPEED": "shot_speed", # int
	"SHOT_DAMAGE": "shot_damage", # float
	"ITEM_DROP": "item_drop" # Object
}

var baddie_scene: PackedScene
var baddie_instance

func _init(baddie_scene: PackedScene, patch: Dictionary = {}):
	baddie_instance = baddie_scene.instance()
	patch_attributes(patch)
	
func build():
	return baddie_instance

func get_attribute(key: String):
	return baddie_instance.attributes.get(key)

func set_attribute(key: String, value) -> BaddieBuilder:
	baddie_instance.attributes.set(key, value)
	return self

func patch_attributes(attributes: Dictionary = {}) -> BaddieBuilder:
	if !attributes.empty():
		baddie_instance.attributes.patch(attributes)
	return self
