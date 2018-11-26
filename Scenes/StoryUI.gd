extends NinePatchRect

# This script handles the placing of narrative text into the appropriate
# text box and choice buttons.

var current_page = {}  # Dictionary that holds all information for the currently displayed page.

func _ready():
#	Add each character to the CharacterUI scene.
	var target_parent_node = $M/FullWidth/Characters
	for i in range( Global.current_characters.size() ):
		var scene = load('res://Scenes/CharacterUI.tscn')
		var scene_instance = scene.instance()
		scene_instance.set_name( 'Character' + str(i) )
		target_parent_node.add_child(scene_instance)
		var new_node = target_parent_node.get_child(i)
	#	Fill in the data on the new node with info from current_characters array (Global).
		new_node.my_index = i
		new_node.char_data = Global.current_characters[i]
		new_node.update_ui(true)


func update_page( target_page_index ):
#	Updates the current page to the target_page_index passed in. This is how we move from page to page.
#	Because target_page_index is passed in pulling from the 'pid' and Twine doesn't start at 0, we need
#		to subtract 1 from the target_page_index.
	target_page_index -= 1
	
	if target_page_index == 0:	# If we're loading the first welcome page...reset hp to maximum for characters.
		for character in Global.current_characters:
			character.current_hp = character.max_hp
			character.current_mp = character.max_mp
		for character in $M/FullWidth/Characters.get_children():
			character.enable()
			character.update_ui(true)
		$M/FullWidth/Main/V/Title/PageTitle.text = Global.full_adventure.name
	else:
		$M/FullWidth/Main/V/Title.hide()
	
	current_page = Global.passages[ target_page_index ]

	if current_page['text'].left(6) == 'COMBAT':	# This is a combat page, special processing.
		var monster_list_text = current_page.text
		var on_win = current_page['links'][0]['pid']
		var on_lose = current_page['links'][1]['pid']
		var combat_node = get_node('/root/Game/CombatUI')
		combat_node.prep_combat(monster_list_text, on_win, on_lose)
		self.hide()
		combat_node.show()
		combat_node.start()

	else:	# This is a normal page, not combat.
		var narrative_box = $M/FullWidth/Main/V/Narrative/PageNarrative
		# Remove The links from the current_page.text
		var cleaned_page_text
		if current_page['text'].find('[[') > 0:
			cleaned_page_text = current_page['text'].left( current_page['text'].find("[[") )
		else:
			cleaned_page_text = current_page['text']
#	Display page narrative text and links.
		narrative_box.bbcode_text = cleaned_page_text
		if current_page.has('links'):
			for i in current_page.links.size():
				var button_scene = load('res://Scenes/ChoiceButton.tscn')
				var button_instance = button_scene.instance()
				button_instance.set_name( 'Choice' + str(i) )
				$M/FullWidth/Main/V/OptionButtons/V.add_child(button_instance)
				var new_node = $M/FullWidth/Main/V/OptionButtons/V.get_child(i)
			#	Fill in the data on the new node with info from character.
				new_node.pid_target = current_page['links'][i]['pid']
				new_node.text = current_page['links'][i]['name']
				if !new_node.is_connected('choice_made', self, 'on_choice_made'):
					new_node.connect('choice_made', self, '_on_choice_made')


func _on_choice_made( pid_target ):
	for child in $M/FullWidth/Main/V/OptionButtons/V.get_children():
		child.get_parent().remove_child(child)
	update_page( int(pid_target) )