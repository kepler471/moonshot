extends Node

var default_baddie_stats = {
	"hp": "",
	"gravity": "",
	"speed": "",
	"direction": "",
	"animation": "",
	"velocity": "",
	"sprite": "",
	"body": "",
	"inflict_damage": ""
}
static func create_baddie_base(stats = {}) -> Baddie:
	var Baddie = load("res://baddies/Baddie.gd").new()
	return Baddie
