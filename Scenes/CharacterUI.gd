extends HBoxContainer

var char_data = {}
var my_index
var selected = false

onready var selected_box = ResourceLoader.load('res://Assets/GUI/SelectedBox.png')
onready var disabled_box = ResourceLoader.load('res://Assets/GUI/DisabledBox.png')

func disable():
	$BG.texture = disabled_box
	$BG/Info/M/V/Name.disabled = true


func enable():
	$BG.texture = null
	$BG/Info/M/V/Name.disabled = false


func activate():
	$BG.texture = selected_box
	$BG/Info/M/V/Name.disabled = false


func update_ui(full):
	if full:
		$BG/Info/M/V/Name.text = char_data['name']
		$BG/Info/M/V/Health.max_value = char_data['max_hp']
		$BG/Info/M/V/Magic.max_value = char_data['max_mp']
		$BG/Image/M/Image.texture_normal = load('res://Assets/Character/' + char_data.pic)
	$BG/Info/M/V/Health.value = char_data['current_hp']
	$BG/Info/M/V/Magic.value = char_data['current_mp']
	if selected:
		$Selected.show()
	else:
		$Selected.hide()
	if char_data['current_hp'] == 0:
		$BG.texture = disabled_box

func _on_Name_pressed():
	# If we are in CombatUI then it selects this character and unselects the rest.
	
	# If we are in StoryUI then pops up the PopupPanel to see full character details.
	
	pass # replace with function body
