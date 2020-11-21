extends Node

static func create(baddie_name: String):
	return load("res://baddies/characters/" + baddie_name + ".tscn")
