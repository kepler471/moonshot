extends Node

static func create(baddie_name: String) -> BaddieInterface:
	return load("res://baddies/" + baddie_name + ".tscn").new()
