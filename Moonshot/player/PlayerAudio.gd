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
	run_streamer.set_bus("Running")
	sliding_streamer.set_bus("Environment")
	jumping_streamer.set_bus("Player")
	pain_streamer.set_bus("Player")
	death_streamer.set_bus("Player")
	sizzle_streamer.set_bus("Environment")
	health_streamer.set_bus("Pickups")
	pickup_streamer.set_bus("Pickups")
	
func _process(delta):
	if not owner.state_machine._state_name == "Wall":
		stop("sliding")

func create_streamer(sound):
	var streamer = AudioStreamPlayer.new()
	streamer.stream = sound
	add_child(streamer)
	return streamer	


func play(sound):
	if not sound_list.has(sound):
		push_error ("SFX not found")
		
	elif sound == "running":
		run_streamer.get_stream().set_loop_mode(1)
		if !run_streamer.is_playing():
			run_streamer.play()
		
	elif sound == "sliding":
		sliding_streamer.play(sound_position)
		
	elif sound == "jumping":
		jumping_streamer.play()
		
	elif sound == "pain":
		pain_streamer.play()

	elif sound == "death":
		death_streamer.play()
		
	elif sound == "sizzle":
		sizzle_streamer.play()
		
	elif sound == "health":
		health_streamer.play()
	
	elif sound == "pickup":
		pickup_streamer.play()
		
func stop(sound):
	if not sound_list.has(sound):
		push_error ("SFX not found")
		
	elif sound == "running":
		run_streamer.get_stream().set_loop_mode(0)
		
	elif sound == "sliding":
		sound_position = sliding_streamer.get_playback_position()
		sliding_streamer.call_deferred("stop")
		
	elif sound == "jumping":
		pass
		
	elif sound == "pain":
		pass

	elif sound == "death":
		pass
		
	elif sound == "sizzle":
		pass
		
	elif sound == "heatlh":
		pass
	
	elif sound == "pickup":
		pass
	

