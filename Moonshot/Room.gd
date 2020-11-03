class_name Room

#Type of room
var type

#keeps track of connected rooms
var nextNodes = []
var prevNodes = []

func _init(typ):
	type = typ

#add connected rooms
func addNext(room):
	nextNodes.append(room)
func addPrev(room):
	prevNodes.append(room)

#remove connected rooms
func removeNext(room):
	var i = nextNodes.find(room)
	if i != -1:
		nextNodes.remove(i)
	else:
		push_warning("Could not find room intended to be removed")
func removePrev(room):
	var i = prevNodes.find(room)
	if i != -1:
		prevNodes.remove()
	else:
		push_warning("Could not find room intended to be removed")

func hasNext():
	if nextNodes.empty():
		return false
	return true
func hasPrev():
	if prevNodes.empty():
		return false
	return true
