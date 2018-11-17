extends HBoxContainer

var char_data = {}
var my_index
export var selected = false
export var active = false
export var enabled = true
export var combat = false

onready var selected_box = ResourceLoader.load('res://Assets/GUI/health-progress-fill.png')
onready var disabled_box = ResourceLoader.load('res://Assets/GUI/DisabledBox.png')
#onready var combat_command_label = get_node('/root/Game/CombatUI/M/V/H/Commands/V/Label')
#onready var combat_command_melee_button = get_node('/root/Game/CombatUI/M/V/H/Commands/V/Melee')




func disable():
	enabled = false
	$M/BG.texture = disabled_box
	$M/BG/Info/M/V/Name.disabled = true


func enable():
	enabled = true
	#$M/BG.texture = null
	$M/BG/Info/M/V/Name.disabled = false


func activate():
	print(char_data['name'], ' is active. Making the texture selected_box.')
	$M/BG.texture = selected_box
	$M/BG/Info/M/V/Name.disabled = false
	active = true
#	if combat:
#		var combat_command_label = get_node('/root/Game/CombatUI/M/V/H/Commands/V/Label')
#		var combat_command_melee_button = get_node('/root/Game/CombatUI/M/V/H/Commands/V/Melee')
#		combat_command_label.text = char_data['name'] + "'s turn:"

func update_ui(full):
	if full:
		$M/BG/Info/M/V/Name.text = char_data['name']
		$M/BG/Info/M/V/Health.max_value = char_data['max_hp']
		$M/BG/Info/M/V/Magic.max_value = char_data['max_mp']
		$M/BG/Image/M/Image.texture_normal = load('res://Assets/Character/' + char_data.pic)
	$M/BG/Info/M/V/Health.value = char_data['current_hp']
	$M/BG/Info/M/V/Magic.value = char_data['current_mp']
	if selected:
		$M/Selected.show()
	else:
		$M/Selected.hide()
	if active: # show the green selected_box
		if combat:
			print('Trying to change texture to selected_box on ', char_data['name'] )
			$M/BG.texture = selected_box
			$M/BG/Info/M/V/Name.disabled = false
			var combat_command_label = get_node('/root/Game/CombatUI/M/V/H/Commands/V/Label')
			var combat_command_melee_button = get_node('/root/Game/CombatUI/M/V/H/Commands/V/MeleeButton')
			combat_command_label.text = char_data['name'] + "'s turn:"
	elif !active:
		if combat:
			print('Making the texture null on ', char_data['name'])
			$M/BG.texture = null
	if enabled:
		enable()
	else:
		disable()
	if char_data['current_hp'] == 0:
		#enabled = false
		disable()



func _on_Name_pressed():
	# If we are in CombatUI then it selects this character and unselects the rest.
	
	# If we are in StoryUI then pops up the PopupPanel to see full character details.
	
	pass # replace with function body
