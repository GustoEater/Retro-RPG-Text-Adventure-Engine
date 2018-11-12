extends NinePatchRect

# This script handles the placing of narrative text into the appropriate
# text box and choice buttons.

#export ( String, FILE, "*.json" ) var adventure_to_load = "res://Data/AdventureParsed.JSON"
#export ( String, FILE, "*.json" ) var current_characters_to_load = "res://Data/Characters.JSON"
#export ( String, FILE, "*.json" ) var characters_to_load = "res://Data/Characters.JSON"
#export ( String, FILE, "*.json" ) var monsters_to_load = "res://Data/Monsters.JSON"
#var full_adventure = {}
var current_page = {}
#var current_characters = []
# This variable is an array of the Character scene / data structure.
#var all_characters = []
#var current_characters = []
#var all_monsters = {}




func _ready():
# Add CharacterUI information.
	var target_parent_node = $M/FullWidth/Characters
	for i in range( Global.current_characters.size() ):
		var scene = load("res://Scenes/CharacterUI.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name( 'Character' + str(i) )
		target_parent_node.add_child(scene_instance)
		var new_node = target_parent_node.get_child(i)
		# Fill in the data on the new node with info from character.
		new_node.my_index = i
		new_node.char_data = Global.current_characters[i]
		new_node.update_ui(true)
		

	#adventure = get_parent().full_adventure
#	# Load the adventure file.
#
#	# opens the file and reads the text into the "full_file_text" variable.
#	var file = File.new()
#	file.open( adventure_to_load, file.READ )
#	var full_file_text = file.get_as_text()
#	file.close()
#
#	# read the "full_file_text" information as a JSON file.
#	var full_file_parse = JSON.parse( full_file_text )
#	if full_file_parse.error == OK:  # If the JSON file was okay, then process it.
#		full_adventure = full_file_parse.result
#		# Here we want to read the first page of the adventure.
	#update_page( "p1" )
#	else:  # If there is an error in the JSON file, then deal with it.
#		print( "Adventure:", full_file_parse.error_line, ", ", full_file_parse.error_string )


	# Load the full character list. This will be all the pre-made characters and the custom ones made

	# opens the file and reads the text into the "full_file_text variable.
#	file = File.new()
#	file.open( characters_to_load, file.READ )
#	full_file_text = file.get_as_text()
#	file.close()
#
#	# read the "full_file_text" information as a JSON file.
#	full_file_parse = JSON.parse( full_file_text )
#	if full_file_parse.error == OK:  # If the JSON file was okay, then process it.
#		all_characters = full_file_parse.result
#	else:  # If there is an error in the JSON file, then deal with it.
#		print( "Characters: ", full_file_parse.error_line, ", ", full_file_parse.error_string )
#
#
#	# For now, we're loading all of the characters, later we will need to work on how this is done.
#	current_characters = all_characters
#	$FullWidth/Character/Character.update_characters( current_characters )

	# THIS STUFF SHOULD PROBABLY BE IN THE GAME NODE SCRIPT (OR THE CHARACTERS NODE SCRIPT)
	# Load the characters into new character nodes and add them as children of "Characters"
	#var character_scene = load("res://Scenes/CharacterNew.tscn")
	#var character_instance = character_scene.instance()
	#character_instance.set_name("Character1")

	#get_parent().add_child()
	# load the variable info.


# Load the full monster list.

	# opens the file and reads the text into the "full_file_text variable.
#	file = File.new()
#	file.open( monsters_to_load, file.READ )
#	full_file_text = file.get_as_text()
#	file.close()
#
#	# read the "full_file_text" information as a JSON file.
#	full_file_parse = JSON.parse( full_file_text )
#	if full_file_parse.error == OK:  # If the JSON file was okay, then process it.
#		all_monsters = full_file_parse.result
#	else:  # If there is an error in the JSON file, then deal with it.
#		print( "Monsters: ", full_file_parse.error_line, ", ", full_file_parse.error_string )



func update_page( target_page ):
	# Updates the current page to the target_page passed in. This is how we move from page to page.
	if Global.full_adventure.has( target_page ):
		current_page = Global.full_adventure[ target_page ]
	else:
		print("Error: The adventure requested a page that does not exist. The request page was ", target_page, ".")

	if current_page[ "title" ] != "COMBAT\n":
		# A standard story element has been chosen.
		var choice0_box = $M/FullWidth/Main/V/OptionButtons/V/Choice0
		var choice1_box = $M/FullWidth/Main/V/OptionButtons/V/Choice1
		var choice2_box = $M/FullWidth/Main/V/OptionButtons/V/Choice2
		var choice3_box = $M/FullWidth/Main/V/OptionButtons/V/Choice3
		var title_box = $M/FullWidth/Main/V/Title/PageTitle
		var narrative_box = $M/FullWidth/Main/V/Narrative/PageNarrative

		# Update screen
		title_box.text = current_page[ "title" ]
		narrative_box.text = current_page[ "narrative" ]
		if current_page.has( "choice0" ):
			choice0_box.text = current_page[ "choice0" ]
			choice0_box.visible = true
		if current_page.has( "choice1" ):
			choice1_box.text = current_page[ "choice1" ]
			choice1_box.visible = true
		else:
			choice1_box.visible = false
		if current_page.has( "choice2" ):
			choice2_box.text = current_page[ "choice2" ]
			choice2_box.visible = true
		else:
			choice2_box.visible = false
		if current_page.has( "choice3" ):
			choice3_box.text = current_page[ "choice3" ]
			choice3_box.visible = true
		else:
			choice3_box.visible = false
	else:
		# Changing to combat mode.
		# Load required information from the current page.
		var monster_list_text = current_page['narrative']
		print("Monster List Text: ", monster_list_text)
		var on_win = current_page['choice-goto0']
		var on_lose = current_page['choice-goto1']
		
		var combat_node = get_node('/root/Game/CombatUI')
		combat_node.prep_combat(monster_list_text, on_win, on_lose)
		self.hide()
		combat_node.show()
		combat_node.start()
		
		
		
		var x = 1   # Run these older things only if things fall apart.
		if x == 0:
			$Combat.monster_list_text = current_page[ "narrative" ]
			$Combat.on_win = current_page[ "choice-goto0" ]
			$Combat.on_lose = current_page[ "choice-goto1" ]

			$Combat.prep_monsters()
			$Combat.popup()
			$Combat.start()
		
		


# All of the below functions move to the new page based on the option selected.
func _on_Choice0_pressed():
	var target_page = current_page[ "choice-goto0" ]
	update_page( target_page )


func _on_Choice1_pressed():
	var target_page = current_page[ "choice-goto1" ]
	update_page( target_page )


func _on_Choice2_pressed():
	var target_page = current_page[ "choice-goto2" ]
	update_page( target_page )


func _on_Choice3_pressed():
	var target_page = current_page[ "choice-goto3" ]
	update_page( target_page )
