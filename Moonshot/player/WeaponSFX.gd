extends Node


var blaster_sfx = load("res://player/assets/sounds/blaster_v1.wav")
onready var blaster_streamer = create_streamer(blaster_sfx)

var mg_sfx = load("res://player/assets/sounds/blaster_v1.wav")
onready var mg_streamer = create_streamer(mg_sfx)

var shotgun_sfx = load("res://player/assets/sounds/shotgun.wav")
onready var shotgun_streamer = create_streamer(shotgun_sfx)

var twin_sfx = load("res://player/assets/sounds/twin.wav")
onready var twin_streamer = create_streamer(twin_sfx)

var sound_list = ["laser_blaster","machine_gun","shotgun","twin_shot"]


func _ready():
	mg_streamer.set_pitch_scale(1.9)
	assign_buses()
	
func _process(_delta):
	pass
	
func create_streamer(sound):
	var streamer = AudioStreamPlayer.new()
	streamer.stream = sound
	add_child(streamer)
	return streamer	

func play(sound):
	if not sound_list.has(sound):
		push_error ("weapon not found")
	
	match sound:
		"laser_blaster":
			blaster_streamer.play()
		"machine_gun":
			mg_streamer.play()
		"shotgun":
			shotgun_streamer.play()
		"twin_shot":
			twin_streamer.play()

func stop(sound):
	if not sound_list.has(sound):
		push_error ("SFX not found")
	
	match sound:
		"laser_blaster":
			blaster_streamer.stop()
		"machine_gun":
			mg_streamer.stop()
		"shotgun":
			shotgun_streamer.stop()
		"twin_shot":
			twin_streamer.stop()

			
func assign_buses():
	blaster_streamer.set_bus("Weapons")
	mg_streamer.set_bus("Weapons")
	shotgun_streamer.set_bus("Weapons")
	twin_streamer.set_bus("Weapons")
	
	
