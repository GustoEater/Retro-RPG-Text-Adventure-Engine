extends NinePatchRect

# This script handles the placing of narrative text into the appropriate
# text box and choice buttons.

var current_page = {}
export (bool) var use_twine = true



func _ready():
#	Add CharacterUI information.
	var target_parent_node = $M/FullWidth/Characters
	for i in range( Global.current_characters.size() ):
		var scene = load('res://Scenes/CharacterUI.tscn')
		var scene_instance = scene.instance()
		scene_instance.set_name( 'Character' + str(i) )
		target_parent_node.add_child(scene_instance)
		var new_node = target_parent_node.get_child(i)
	#	Fill in the data on the new node with info from character.
		new_node.my_index = i
		new_node.char_data = Global.current_characters[i]
		new_node.update_ui(true)


func update_page_twine( target_page_index ):
	print( 'update_page_twine(', str(target_page_index), ')' )
	#if target_page_index > 0:
	#	target_page_index -= 1
#	Updates the current page to the target_page passed in. This is how we move from page to page.
	current_page = Global['passages'][ target_page_index ]
	var narrative_box = $M/FullWidth/Main/V/Narrative/PageNarrative
	narrative_box.bbcode_text = current_page.text
	# First hide all of the buttons
	for button in $M/FullWidth/Main/V/OptionButtons/V.get_children():
		button.hide()
	if current_page.has('links'):
		print('There are ', current_page['links'].size() , ' items in the links array: ', current_page.links )
		#if current_page.links.size() > 0:
	#	There are links in the page, we should display those
		# Show each button with the correct text.
		for i in current_page.links.size():
			$M/FullWidth/Main/V/OptionButtons/V.get_child(i).text = current_page['links'][i]['name']
			$M/FullWidth/Main/V/OptionButtons/V.get_child(i).show()
			#choice0_box.text = current_page['links'][0]['name']
			 


func update_page( target_page ):
	if use_twine:
	#	Translate 'target_page' into an indix number for 'target_page_index'.
		
		update_page_twine(0)
	else:
	#	Updates the current page to the target_page passed in. This is how we move from page to page.
		if Global.full_adventure.has( target_page ):
			current_page = Global.full_adventure[ target_page ]
		else:
			print('Error: The adventure requested a page that does not exist. The requested page was ', target_page, '.')
	
		if current_page[ 'title' ] != 'COMBAT\n':  # A standard story element has been chosen.
			var choice0_box = $M/FullWidth/Main/V/OptionButtons/V/Choice0
			var choice1_box = $M/FullWidth/Main/V/OptionButtons/V/Choice1
			var choice2_box = $M/FullWidth/Main/V/OptionButtons/V/Choice2
			var choice3_box = $M/FullWidth/Main/V/OptionButtons/V/Choice3
			var title_box = $M/FullWidth/Main/V/Title/PageTitle
			var narrative_box = $M/FullWidth/Main/V/Narrative/PageNarrative
	
			# Update screen
			title_box.text = current_page[ 'title' ]
			# Need to remove all "\r" from the narrative block.
			var new_narrative = current_page.narrative.replace('\r', '')
			narrative_box.bbcode_text = new_narrative
			#print(narrative_box.bbcode_text)
			if current_page.has( 'choice0' ):
				choice0_box.text = current_page[ 'choice0' ]
				choice0_box.visible = true
			if current_page.has( 'choice1' ):
				choice1_box.text = current_page[ 'choice1' ]
				choice1_box.visible = true
			else:
				choice1_box.visible = false
			if current_page.has( 'choice2' ):
				choice2_box.text = current_page[ 'choice2' ]
				choice2_box.visible = true
			else:
				choice2_box.visible = false
			if current_page.has( 'choice3' ):
				choice3_box.text = current_page[ 'choice3' ]
				choice3_box.visible = true
			else:
				choice3_box.visible = false
	
		else:  # Changing to combat mode.
		#	Load required information
			var monster_list_text = current_page['narrative']
			var on_win = current_page['choice-goto0']
			var on_lose = current_page['choice-goto1']
			var combat_node = get_node('/root/Game/CombatUI')
			combat_node.prep_combat(monster_list_text, on_win, on_lose)
			self.hide()
			combat_node.show()
			combat_node.start()


# All of the below functions move to the new page based on the option selected.
func _on_Choice0_pressed():
	if use_twine:
		print( 'Click going to target_page_index: ', str( int(current_page['links'][0]['pid']) - 1 ) )
		update_page_twine( int( current_page['links'][0]['pid'] ) - 1 )

	else:
		var target_page = current_page[ 'choice-goto0' ]
		update_page( target_page )

func _on_Choice1_pressed():
	if use_twine:
		print( 'Click going to target_page_index: ', str( int(current_page['links'][0]['pid']) - 1 ) )
		update_page_twine( int( current_page['links'][1]['pid'] ) - 1 )

	else:
		var target_page = current_page[ 'choice-goto1' ]
		update_page( target_page )

func _on_Choice2_pressed():
	if use_twine:
		print( 'Click going to target_page_index: ', str( int(current_page['links'][0]['pid']) - 1 ) )
		update_page_twine( int( current_page['links'][2]['pid'] ) - 1 )

	else:
		var target_page = current_page[ 'choice-goto2' ]
		update_page( target_page )

func _on_Choice3_pressed():
	if use_twine:
		print( 'Click going to target_page_index: ', str( int(current_page['links'][0]['pid']) - 1 ) )
		update_page_twine( int( current_page['links'][3]['pid'] ) - 1 )

	else:
		var target_page = current_page[ 'choice-goto3' ]
		update_page( target_page )