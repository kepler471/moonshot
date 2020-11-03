extends Node
const Room = preload("res://Room.gd")

#set up random number generator
var rng = RandomNumberGenerator.new();

#constraint variables
var minNodes : int = 5
var maxNodes : int = 10
var rooms = []

func getNewRoomAtWeight(weight) -> Room:
	for i in Global.roomTypes:
		weight -= Global.roomTypes[i]
		if weight <= 0:
			return Room.new(i)
	push_warning("Room type out of bounds")
	return Room.new(Global.roomTypes[0])

func _ready():
	
	#randomize generator seed using system time
	rng.randomize()
	
	#figure out how many nodes we're going to make
	var numberOfRooms = rng.randi_range(minNodes, maxNodes)
	
	#get total room weight
	var totalWeight = 0
	for i in Global.roomTypes.values():
		totalWeight += i
	
	#generate a line of rooms
	var currentWeight = 0
	for i in range(numberOfRooms):
		currentWeight = rng.randi_range(1, totalWeight)
		rooms.append(getNewRoomAtWeight(currentWeight))
		if i > 0:
			rooms[i-1].addNext(rooms[i])
			rooms[i].addPrev(rooms[i-1])
	
	#draw
	drawRoomsTree(rooms)
	
	
func drawRoomsTree(roomList):
	var treeNode = preload("res://TreeNode.tscn")
	var treeConnector = preload("res://TreeNodeConnector.tscn")
	var currentPos = Vector2(50,50)
	
	if roomList.empty():
		return
	
	var currentRoom = roomList[0]
	
	#to hold instances while we need them
	var r
	#assume straight line for now
	while currentRoom.hasNext():
		#add node
		r = treeNode.instance()
		r.position = currentPos
		add_child(r)
		#add connector to next
		r = treeConnector.instance()
		r.position = currentPos + Vector2(100,45)
		add_child(r)
		#go to next room
		currentRoom = currentRoom.nextNodes[0]
		currentPos.x += 110
		
	r = treeNode.instance()
	r.position = currentPos
	add_child(r)
