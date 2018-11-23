extends Button

var pid_target
onready var story_node = get_node('/root/Game/StoryUI')

signal choice_made (pid_target)


func _on_Choice_pressed():
	get_parent().remove_child(self)
	emit_signal('choice_made', pid_target)