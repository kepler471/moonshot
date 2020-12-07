extends RigidBody2D

signal animation_finished

onready var animation: AnimationPlayer = $AnimatedSprite/AnimationPlayer
onready var anim_sprite: AnimatedSprite = $AnimatedSprite
var _contacts = []
var _contact_tiles = []
#Fetch the breakable tile map
onready var breakable_tilemap = get_parent().get_node("BreakableTiles")
onready var tilemap = get_parent().get_node("BaseTiles")

var f_mag = 800
var damage = 0.4


func _ready():
	apply_impulse(Vector2(100,100).rotated(rotation), Vector2(f_mag, 0).rotated(rotation))
	if !animation.is_connected("animation_finished", self, "_on_AnimationPlayer_animation_finished"):
		animation.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	# Ranomize the starting frameof the animation
	randomize()
	animation.play("default")
	var offset : float = rand_range(0, animation.current_animation_length)
	animation.advance(offset)


func _on_any_body_entered(body):
	if body.is_in_group("Baddies"):
		CombatSignalController.emit_signal("damage_baddie",body.get_instance_id(), damage)

	if !body.is_in_group("Player"):
		_destroy()
		_play_hit_animation()


func _destroy():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	set_linear_velocity(Vector2.ZERO)


func _play_hit_animation():
	animation.play("hit")
	var rotation : float = rand_range(0, 2*PI)
	anim_sprite.rotation = rotation


func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	emit_signal("animation_finished", anim_name)
	if anim_name == "hit":
		call_deferred("free")
		
func _integrate_forces(state):

	if breakable_tilemap:
		for i in range(state.get_contact_count()):
			
			# Just gather contact points in an array to draw them later
			var contact_pos = state.get_contact_local_position(i)
			_contacts.append(contact_pos)
			
			var tile_pos = breakable_tilemap.world_to_map(contact_pos)
			_contact_tiles.append(tile_pos)
		
		
	update()

# Damage tiles if breakable
func _on_RigidBody2D_tree_exited():
	if len(_contact_tiles) > 0:
		for tile in _contact_tiles:
			TileSheetLoader.damage_breakable_tile(tilemap, breakable_tilemap,_contact_tiles[0])
		
		
