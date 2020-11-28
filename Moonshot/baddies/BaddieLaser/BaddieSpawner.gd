extends Position2D
class_name BaddieSpawner

var chick = load("res://baddies/characters/Chick.tscn")
var baddie_builder = load("res://procedural_map_generation/BaddieBuilder.gd")
var max_baddies = 8 setget set_max_baddies
var _baddie_dictionary: Dictionary = {}
var spawn_dir : float

func set_max_baddies(m: int) -> void:
	max_baddies = m

func spawn_randomly() -> void:
	spawn()

func set_direction(x: float) -> void:
	spawn_dir = sign(x)

func spawn():
	print("Spawned")
	var baddie_dictionary_keys: Array = _baddie_dictionary.keys()
	if _is_max_capacity(baddie_dictionary_keys):
		return

	var builder = baddie_builder.new(chick, { "inital_hp": 0.75, "hp": 0.75})
	var baddie_instance = builder.build()

	baddie_instance.set_mother_dir(spawn_dir)
	print("spawner dir ::: ", spawn_dir)

	baddie_instance.position = global_position
	_baddie_dictionary[baddie_instance.get_instance_id()] = baddie_instance

	_add_baddie_to_scene(baddie_instance)
	_clean_dictionary(baddie_dictionary_keys)

func _is_max_capacity(baddie_dictionary_keys: Array) -> bool:
	return baddie_dictionary_keys.size() > max_baddies

func _add_baddie_to_scene(baddie_instance: Node) -> void:
	var parent = get_parent()

	if  Utils.is_nil(parent):
		return
		
	var scene = parent.get_parent()
	if  Utils.is_nil(scene):
		return

	scene.call_deferred("add_child", baddie_instance)

# ensures we never go over `n` baddies and resizes dictionary
func _clean_dictionary(keys: Array) -> void:
	for key in keys:
		if  Utils.is_nil(_baddie_dictionary.get(key)):
			_baddie_dictionary.erase(key)
