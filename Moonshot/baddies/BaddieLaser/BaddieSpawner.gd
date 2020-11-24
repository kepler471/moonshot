extends Position2D
class_name BaddieSpawner

var bearBoi = load("res://baddies/characters/BearBoi.tscn")
var baddie_builder = load("res://procedural_map_generation/BaddieBuilder.gd")
var max_baddies = 5 setget set_max_baddies
var _baddie_dictionary: Dictionary = {}

func set_max_baddies(m: int) -> void:
	max_baddies = m

func spawn_randomly() -> void:
	spawn()
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.start(0.5)

func spawn():
	var baddie_dictionary_keys: Array = _baddie_dictionary.keys()
	if _is_max_capacity(baddie_dictionary_keys):
		return

	var builder = baddie_builder.new(bearBoi, { "inital_hp": 0.75, "hp": 0.75 })
	var baddie_instance = builder.build()

	baddie_instance.position = global_position -  Vector2(0.75, 0.75) # slightly beneath mother hen
	baddie_instance.scale = Vector2(0.75, 0.75) # smaller

	_baddie_dictionary[baddie_instance.get_instance_id()] = baddie_instance

	_add_child(baddie_instance)
	_clean_dictionary(baddie_dictionary_keys)
	
func _add_child(baddie_instance: Node) -> void:
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

func _is_max_capacity(baddie_dictionary_keys: Array) -> bool:
	return baddie_dictionary_keys.size() > max_baddies
