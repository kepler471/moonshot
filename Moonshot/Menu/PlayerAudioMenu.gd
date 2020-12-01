extends Node

var rng = RandomNumberGenerator.new()

var running_sfx = load("res://player/assets/sounds/metalrunning.wav")
onready var run_streamer = create_streamer(running_sfx)

var jumping_sfx = load("res://player/assets/sounds/jump.wav")
onready var jumping_streamer = create_streamer(jumping_sfx)

var sound_list = ["running","jumping"]

var sound_position = 0

func _ready():
	assign_buses()
	rng.randomize()
		

func create_streamer(sound):
	var streamer = AudioStreamPlayer.new()
	streamer.stream = sound
	add_child(streamer)
	return streamer	


func play(sound):
	if not sound_list.has(sound):
		push_error ("SFX not found")
	
	match sound:
		"running":
			run_streamer.set_pitch_scale(rng.randf_range(0.95,1.05))
			run_streamer.get_stream().set_loop_mode(1)
			if !run_streamer.is_playing(): #stop steps layering
				run_streamer.play()
		"jumping":
			jumping_streamer.play()

func stop(sound):
	if not sound_list.has(sound):
		push_error ("SFX not found")
	
	match sound:
		"running":
			run_streamer.get_stream().set_loop_mode(0) #let last step play to finish
		"jumping":
			jumping_streamer.stop()
			
func assign_buses():
	run_streamer.set_bus("Running")
	jumping_streamer.set_bus("Player")
	
