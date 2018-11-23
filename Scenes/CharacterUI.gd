extends HBoxContainer

var char_data = {}
var my_index
export var selected = false
export var active = false
export var enabled = true
export var in_combat = false

onready var selected_box = ResourceLoader.load('res://Assets/GUI/SelectedBox.png')
onready var disabled_box = ResourceLoader.load('res://Assets/GUI/DisabledBox.png')


func disable():	# This status means the character is dead.
	enabled = false
	$M/BG.texture = disabled_box
	$M/BG/Info/M/V/Name.disabled = true


func enable():	# This status means the character is not dead.
	enabled = true
	$M/BG/Info/M/V/Name.disabled = false


func activate():	# This status means the character is conducting it's turn.
	$M/BG.texture = selected_box
	$M/BG/Info/M/V/Name.disabled = false
	active = true


func update_ui(full_update):
	if full_update:	# Certain items are done only occasionally.
		$M/BG/Info/M/V/Name.text = char_data['name']
		$M/BG/Info/M/V/H/Health.max_value = char_data['max_hp']
		$M/BG/Info/M/V/H2/Magic.max_value = char_data['max_mp']
		$M/BG/Image/M/Image.texture_normal = load('res://Assets/Character/' + char_data.pic)

	$M/BG/Info/M/V/H/Health.value = char_data['current_hp']
	$M/BG/Info/M/V/H2/Magic.value = char_data['current_mp']
	if selected:
		$M/Selected.show()
	else:
		$M/Selected.hide()
	if active: # show the green selected_box
		if in_combat:
			$M/BG.texture = selected_box
			$M/BG/Info/M/V/Name.disabled = false
			var combat_command_label = get_node('/root/Game/CombatUI/M/V/H/Commands/V/Main')
			var combat_command_melee_button = get_node('/root/Game/CombatUI/M/V/H/Commands/V/H4/MeleeButton')
			var combat_command_range_button = get_node('/root/Game/CombatUI/M/V/H/Commands/V/H4/RangeButton')
			var combat_command_wand_button = get_node('/root/Game/CombatUI/M/V/H/Commands/V/H4/WandButton')
			combat_command_label.text = char_data['name'] + "'s turn:"

			if char_data['weapons'].has('melee'):
				combat_command_melee_button.show()
			else:
				combat_command_melee_button.hide()

			if char_data['weapons'].has('range'):
				#combat_command_range_button.text = 'Attack: ' + char_data['weapons']['range']
				combat_command_range_button.show()
			else:
				combat_command_range_button.hide()

			if char_data['weapons'].has('wand'):
				#combat_command_wand_button.text = 'Attack: ' + char_data['weapons']['wand']
				combat_command_wand_button.show()
			else:
				combat_command_wand_button.hide()

	elif !active:
		if in_combat:
			$M/BG.texture = null
	if enabled:
		enable()
	else:
		disable()
	if char_data['current_hp'] == 0:
		#enabled = false
		disable()
# Health and Magic Values
	var health_text = str( char_data['current_hp'] ) + ' / ' + str( char_data['max_hp'] )
	var magic_text = str( char_data['current_mp'] ) + ' / ' + str( char_data['max_mp'] )
	$M/BG/Info/M/V/H/BG/HealthText.text = health_text
	$M/BG/Info/M/V/H2/BG/MagicText.text = magic_text


func _on_Name_pressed():
	# If we are in CombatUI then it selects this character and unselects the rest.
	
	# If we are in StoryUI then pops up the PopupPanel to see full character details.
	
	pass # replace with function body
