extends RichTextLabel

onready var character_box = get_parent().get_node("CharacterName")
var dialog = StoryText.initial_story
var page = 0


func start_dialog():
	character_box.set_bbcode(dialog[page]["character"])
	set_bbcode(dialog[page]["text"])
	set_visible_characters(0)
	set_process_input(true)
	
	
func _input(event):
	if (event is InputEventMouseButton and event.is_pressed()) or event.is_action_pressed("click"):
		if get_visible_characters() > get_total_character_count():
			if page < dialog.size() - 1:
				page += 1
				character_box.set_bbcode(dialog[page]["character"])
				set_bbcode(dialog[page]["text"])
				set_visible_characters(0)
			else:
				owner.set_visible(false)
		else:
			set_visible_characters(get_total_character_count())
			
			
func _on_Timer_timeout():
	set_visible_characters(get_visible_characters()+1)
