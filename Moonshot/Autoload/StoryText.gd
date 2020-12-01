extends Node

var initial_story = [
	{"character": "Radio Controller", "text": "Sir, you're all thats left. We\'ve lost contact with all the others who have gone down into the core."},
	{"character": "Radio Controller", "text": "Thank god that you are our most experiened scientist. I have complete faith in your ability to stop the infection."},
	{"character": "Radio Controller", "text": "..."},
	{"character": "Radio Controller", "text": "Hold on, I'm getting an incoming message from the chief scientist ... Wait, so who are you?"},
	{"character": "Radio Controller", "text": "*Radio Patching*"},
	{"character": "Chief Scientist", "text": "INTERN! WHAT HAVE YOU DONE! HOW DID YOU MANAGE TO CONFUSE OUR SCHEDULES???"},
	{"character": "Chief Scientist", "text": "IF YOU DON'T GET DOWN TO THE CORE NOW TO ADMINISTER THE ANTIDOTE, THEN YOU CAN KISS YOUR JOB AND YOUR LIFE GOODBYE!"}
	]

var level_entry_story = {
	1: [
		{"character": "Radio Controller", "text": "Good luck intern. There are old mining lifts on each floor that will take you down towards the core."},
		{"character": "Radio Controller", "text": "Unfortunatly we have lost the cave maps so you will have to find the lifts yourself. We aren't sure how deep it runs but as we recieve more data from your suit we will update you."},
		{"character": "Radio Controller", "text": "You can use the infection orbs collected by your suit to power up your weapon, but any knock to the suit and they will be damaged."},
		{"character": "Radio Controller", "text": "Keep moving, and stay alive."},
		{"character": "Radio", "text": "*Transmission terminated*"},
		],
	2: [
		{"character": "Radio Controller", "text": "Well done you found the first lift, I remember now that the caves get larger as you go down so don't slow down now."},
		{"character": "Radio", "text": "*Transmission terminated*"}],
		
	3: [
		{"character": "Radio Controller", "text": "Intern are you there?"},
		{"character": "Radio Controller", "text": "These readings, they don't seem to make sense. It looks like the infection is man made... sorry the Chief Scientist is back, I have to go."},
		{"character": "Radio", "text": "*Transmission terminated*"}
	],
	4: [
		{"character": "Radio Controller", "text": "Intern, listen quickly."},
		{"character": "Radio Controller", "text": "I'm starting to have concerns about the Chief, he has been behaving more and more erratically. There are suggestions that he may have had something to do with the the infection in the first place to procure the contract for removing it. Don't trust him."},
		{"character": "Radio Controller", "text": "*Transmission terminated*"}],
		
	5: [
		{"character": "Radio Controller", "text": "I know the Chief is involved. "},
		{"character": "Radio Controller", "text": "You will also be glad to hear that this is the final cave, I'm not getting any infection readings closer to the core."},
		{"character": "Radio Controller", "text": "If... *cough*... When you have cleared this floor I will use the data from your suit to prove the chief started the infection. "},
		{"character": "Radio Controller", "text": "The board will hear about it and he will be terminated."},
		{"character": "Radio Controller", "text": "I need to be careful or he will..."},
		{"character": "Radio", "text": "**Radio Signal Lost*"}
		]
}

var end_story = [
	{"character": "Radio Controller", "text": "Good work Intern. We have stopped picking up signals from the infection, you can return home we will prepare to send a shuttle."},
	{"character": "Radio", "text": "..."},
	{"character": "Chief Scientist", "text": "CONTROLLER WHAT ARE YOU TALKING ABOUT, YOUR NEED TO SCROLL DOWN. YOURE FIRED!"},
	{"character": "Radio Controller", "text": "No, please no! Not me!! Not like the others!! PLEA..."},
	{"character": "Radio", "text": "*Screams*"},
	{"character": "Chief Scientist", "text": "INTERN, GET BACK TO WORK."},
	{"character": "Radio", "text": "*Transmission terminated*"}]
	


func _ready():
	pass
