extends Node


var running_sfx = load("res://player/assets/sounds/running.wav")
onready var run_streamer = create_streamer(running_sfx)

var sliding_sfx = load("res://player/assets/sounds/wallsliding.wav")
onready var sliding_streamer = create_streamer(sliding_sfx)

var jumping_sfx = load("res://player/assets/sounds/jump.wav")
onready var jumping_streamer = create_streamer(jumping_sfx)

var pain_sfx = load("res://player/assets/sounds/paingrunt.wav")
onready var pain_streamer = create_streamer(pain_sfx)

var death_sfx = load("res://player/assets/sounds/deathgrunt.wav")
onready var death_streamer = create_streamer(death_sfx)

var sizzle_sfx = load("res://player/assets/sounds/sizzle.wav")
onready var sizzle_streamer = create_streamer(sizzle_sfx)

var health_sfx = load("res://player/assets/sounds/healthpickup.wav")
onready var health_streamer = create_streamer(health_sfx)

var pickup_sfx = load("res://player/assets/sounds/game-pick-up-object.wav") 
onready var pickup_streamer = create_streamer(pickup_sfx)

var sound_list = ["running","sliding","jumping","pain","death","sizzle","health","pickup"]

var sound_position = 0

func _ready():
	assign_buses()
	
func _process(delta):
	if not owner.state_machine._state_name == "Wall": #fix stuck sliding sound 
		stop("sliding")

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
			run_streamer.get_stream().set_loop_mode(1)
			if !run_streamer.is_playing(): #stop steps layering
				run_streamer.play()
		"sliding":
			sliding_streamer.play(sound_position)
		"jumping":
			jumping_streamer.play()
		"pain":
			pain_streamer.play()
		"death":
			death_streamer.play()
		"sizzle":
			sizzle_streamer.play()
		"health":
			health_streamer.play()
		"pickup":
			pickup_streamer.play()

func stop(sound):
	if not sound_list.has(sound):
		push_error ("SFX not found")
	
	match sound:
		"running":
			run_streamer.get_stream().set_loop_mode(0) #let last step play to finish
		"sliding":
			sound_position = sliding_streamer.get_playback_position() #stop sliding sound repitition
			sliding_streamer.stop()
		"jumping":
			jumping_streamer.stop()
		"pain":
			pain_streamer.stop()
		"death":
			death_streamer.stop()
		"sizzle":
			sizzle_streamer.stop()
		"health":
			health_streamer.stop()
		"pickup":
			pickup_streamer.stop()
			
func assign_buses():
	run_streamer.set_bus("Running")
	sliding_streamer.set_bus("Environment")
	jumping_streamer.set_bus("Player")
	pain_streamer.set_bus("Player")
	death_streamer.set_bus("Player")
	sizzle_streamer.set_bus("Environment")
	health_streamer.set_bus("Pickups")
	pickup_streamer.set_bus("Pickups")
	
