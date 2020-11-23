extends RigidBody2D


const PICK_UP_TRAVEL_SPEED = 0.01
var damage = 0.4 setget set_damage


func _ready():
	CombatSignalController.connect("emit_player_global_position_drop", self, "move_to_player")
	

func move_to_player(player_global_position):
	var shot_direction: Vector2 = (player_global_position - get_global_position()).normalized()
	self.position = self.global_position + (shot_direction * 0.01)
	self.apply_central_impulse(shot_direction * PICK_UP_TRAVEL_SPEED)
	self.rotation = PI + self.position.angle_to_point(player_global_position)


func _on_BubbleBeam_body_entered(body):
	if body.is_in_group("Player"):
#		if Utils.IS_DEBUG: 
		print("hit by beam with x := ", position)
		CombatSignalController.emit_signal("damage_player", damage, position)
	call_deferred("free")


func set_damage(d: float) -> void:
	damage = d
