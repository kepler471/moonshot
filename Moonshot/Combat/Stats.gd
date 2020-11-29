# Stats for the player or the monsters, to manage health, etc.
# Attach an instance of Stats to any object to give it health and stats.
extends Node

class_name Stats

signal health_changed(old_value, new_value)
signal health_depleted()
signal damage_taken()
signal firerate_changed(new_firerate, firerate_level)

var modifiers = {"firerate_pickups": 0, "firerate": 1}
var no_firerate_pickups_to_increase_firerate = 2
var firerate_scaling_factor = 1.2
var max_firerate_level = 5
var unlocked_firerate_level = 2
var current_firerate_level = 0

var invulnerable := false

export var max_health := 5.0 setget set_max_health, get_max_health
var health := max_health

export var attack: int = 1
export var armor: int = 1


func _ready() -> void:
	health = max_health


func heal(amount: float) -> void:
	var old_health = health
	health = min(health + amount, max_health)
	emit_signal("health_changed", health, old_health)


func set_max_health(value: float) -> void:
	if value == null:
		return
	max_health = max(max_health, value)
	
func get_max_health() -> float:
	return max_health


func add_modifier(id: int, modifier) -> void:
	modifiers[id] = modifier


func remove_modifier(id: int) -> void:
	modifiers.erase(id)


func set_invulnerable_for_seconds(time: float) -> void:
	invulnerable = true

	var timer := get_tree().create_timer(time)
	yield(timer, "timeout")

	invulnerable = false
	
func pickup_firerate(increase):
	modifiers['firerate_pickups'] += increase 
	modifiers['firerate_pickups'] = min(modifiers['firerate_pickups'], no_firerate_pickups_to_increase_firerate*unlocked_firerate_level)
	current_firerate_level = floor(modifiers['firerate_pickups'] / no_firerate_pickups_to_increase_firerate) + 1
	modifiers['firerate'] = pow(firerate_scaling_factor, current_firerate_level)
	emit_signal("firerate_changed", modifiers['firerate_pickups'], current_firerate_level)
		
func take_damage(level_of_decrease):
	drop_firerate(1)
	health -= level_of_decrease
	
func drop_firerate(lvls_to_drop):
	if modifiers['firerate_pickups'] > 0:
		modifiers['firerate_pickups'] -= no_firerate_pickups_to_increase_firerate*lvls_to_drop
		modifiers['firerate_pickups'] = max(modifiers['firerate_pickups'], 0)
		current_firerate_level = floor(modifiers['firerate_pickups'] / no_firerate_pickups_to_increase_firerate) + 1
		modifiers['firerate'] = pow(firerate_scaling_factor, current_firerate_level)
		emit_signal("firerate_changed", modifiers['firerate_pickups'], current_firerate_level)
	
	

func unlock_firerate_level():
	unlocked_firerate_level += 1
	unlocked_firerate_level = min(max_firerate_level, unlocked_firerate_level)
