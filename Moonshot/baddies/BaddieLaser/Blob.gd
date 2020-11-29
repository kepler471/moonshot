extends RigidBody2D

const PLAYER_SIGNAL = "emit_player_global_position_drop"
const MOVE_TO_PLAUER = "move_to_player"
const targeting_travel_speed = 0.03
var damage = 0.4 setget set_damage

func _ready():
	_connect()

func move_to_player(player_global_position):
	if !is_inside_tree() && _is_connected():
		CombatSignalController.disconnect(PLAYER_SIGNAL, self, MOVE_TO_PLAUER);
	else:
		if !_is_connected():
			_connect()
		float_to_player(player_global_position)

func _connect() -> void:
	CombatSignalController.connect(PLAYER_SIGNAL, self, MOVE_TO_PLAUER)

func _is_connected() -> bool:
	return CombatSignalController.is_connected(PLAYER_SIGNAL, self, MOVE_TO_PLAUER)

func float_to_player(player_global_position) -> void:
	var shot_direction: Vector2 = (player_global_position - get_global_position()).normalized()
	self.position = self.global_position + (shot_direction * targeting_travel_speed)
	self.apply_central_impulse(shot_direction * targeting_travel_speed)
	self.rotation = PI + self.position.angle_to_point(player_global_position)

func _on_Blob_body_entered(body):
	if body.is_in_group("Player"):
		CombatSignalController.emit_signal("damage_player", damage, position)
	call_deferred("free")

func set_damage(d: float) -> void:
	damage = d
