extends Polygon2D

func _ready():
	pass

func assign_script(story):
	match story:
		"initial_story":
			$RichTextLabel.dialog = StoryText.initial_story
		
		"level_entry_story":
			var level_no = get_tree().get_current_scene().level_no
			$RichTextLabel.dialog = StoryText.level_entry_story[level_no]
		
		"end_story":
			$RichTextLabel.dialog = StoryText.end_story

func start_dialog():
	$RichTextLabel.start_dialog()
