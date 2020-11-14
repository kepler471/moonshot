extends Node2D

signal damage_player
signal damage_baddie

var Player
var Baddie_Dictionary: Dictionary = {}

func set_player(p) -> void:
	Player = p

func set_baddie(b) -> void:
	if b == null: return
	
	b.connect("damage_player", Player, "receive_damage")
	Baddie_Dictionary[b.get_instance_id()] = b

func set_many_baddies(bs) -> void:
	for b in bs: set_baddie(b)
