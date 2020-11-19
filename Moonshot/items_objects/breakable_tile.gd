extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var max_hp = 1
var hp = 1

var block_tex1 = preload("res://items_objects/assets/TealBreakableTile1.png")
var block_tex2  = preload("res://items_objects/assets/TealBreakableTile2.png")
var block_tex3  = preload("res://items_objects/assets/TealBreakableTile3.png")
export(Texture) var block_tex_1
export(Texture) var block_tex_2
export(Texture) var block_tex_3


# Called when the node enters the scene tree for the first time.
func _ready():
	CombatSignalController.connect("damage_baddie", self, "on_hit")
	

func on_hit(instance_id, damage):
	if instance_id == self.get_instance_id():
		on_struck(damage)
		
func on_struck(damage: float) -> void:
	hp -= damage
	if hp <= 0:
		on_death()
	elif hp < (max_hp / 0.4):
		switch_texture(3)
	elif hp < (max_hp / 0.2):
		switch_texture(2)
	elif hp < ((0.3*max_hp) / 0.4):
		switch_texture(1)

func on_death() -> void:
	call_deferred("free")
	

func switch_texture(num):
	if  (num == 1):
		$Sprite.texture = block_tex_1
	elif(num == 2):
		$Sprite.texture = block_tex_2
	else:
		$Sprite.texture = block_tex_3

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
