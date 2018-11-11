extends NinePatchRect

#var current_monster_list = []
#export var monsters = {}
onready var commentary = $M/V/H2/BG/M/Commentary

var num_of_fighters
var active_character
var active_monster

onready var selected_box = ResourceLoader.load("res://Assets/GUI/SelectedBox.png")

signal turn_completed




func _ready():
	# Add CharacterUI information.
	var target_parent_node = $M/V/H/Characters
	for i in range( Global.current_characters.size() ):
		var scene = load("res://Scenes/CharacterUI.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name( 'Character' + str(i) )
		target_parent_node.add_child(scene_instance)
		var new_node = target_parent_node.get_child(i)
		# Fill in the data on the new node with info from character.
		new_node.my_index = i
		new_node.update_ui()



func prep_monsters(list, on_win, on_lose):
	var number_of_monsters = list.left( list.findn( ":" ) )
	list = list.right( list.findn( ":" ) + 1 )
	# remove leading \n\r\n from the beginning.
	list = list.right ( 3 )

	# separate each monster (monster_list) into our list of monsters.
	for i in range( number_of_monsters ):
		Global.current_monster_list.append( list.left( list.findn( "\n" ) ) )
		list = list.right( Global.current_monster_list[i].length() + 3 )
		Global.current_monster_list[ i ] = Global.current_monster_list[ i ].right( 1 )
		Global.current_monster_list[ i ] = Global.current_monster_list[ i ].left( Global.current_monster_list[ i ].length() - 1 )
	
	# Load monsters into the monsters array.
	# load the appropriate monsters into the monsters array.
#	for i in range( Global.current_monster_list.size() ):
#		#monsters.append( get_parent().all_monsters[ monster_list[ i ] ])
#		monsters = Global.all_monsters.duplicate()
		#print( monster_list[i] )
		#print( monsters[ monster_list[i] ] )

	# Update the "hp" for each monster using their "hit dice"
	#print( monsters.size() )
	for i in range( Global.current_monster_list.size() ):
		var hd = Global.all_monsters[ Global.current_monster_list[i] ][ "hit_dice" ]
		#print("Hit Dice: ", hd )
		var hp = roll_dice( hd )
		#print("Hit Points: ", hp )
		Global.all_monsters[ Global.current_monster_list[i] ]["max_hp"] = hp
		if Global.all_monsters[ Global.current_monster_list[i] ].has('current_hp'):
			Global.all_monsters[ Global.current_monster_list[i] ]["current_hp"] = hp
#		print( monsters[ i ][ "current_hp" ] )
	
	# Add the Monster Information to the screen. (under "$MarginContainer/HBoxContainer/Monsters"
	# This should include a label, a picture, a health bar.
	for i in range( Global.current_monster_list.size() ):
		pass
# Add MonsterUI information.
	var target_parent_node = $M/V/H/Monsters
	for i in range( Global.current_monster_list.size() ):
		var scene = load("res://Scenes/MonsterUI.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name( 'Monster' + str(i) )
		target_parent_node.add_child(scene_instance)
		var new_node = target_parent_node.get_child(i)
		# Fill in the data on the new node with info from character.
		new_node.my_index = i
		new_node.update_ui()
	
	


func roll_dice( string ):
	# This function takes an input string like "1d6" and rolls the appropriate dice.
	# Parse the string.
	var sum = 0
	var number = int( string.left( string.findn( "d" ) ) )
	var type = int( string.right( string.length() - string.findn( "d" ) ) )
	for i in range( number ):
		randomize()
		sum += randi() % type + 1
	return sum



func start():
	# Begins the combat loop.
	var opening_message = "You are fighting a "
	for i in range( Global.current_monster_list.size() ):
		if i < Global.current_monster_list.size() - 2 :
			opening_message += Global.all_monsters[ Global.current_monster_list[i] ]["name"] + ", a "
		elif i < Global.current_monster_list.size() - 1:
			opening_message += Global.all_monsters[ Global.current_monster_list[i] ]["name"] + ", and a "
		else:
			opening_message += Global.all_monsters[ Global.current_monster_list[i] ]["name"] + "."

	#print( opening_message )
	commentary.text = commentary.text + opening_message

	# Roll Initiative.
	roll_initiative()
	battle()



func battle():
	# function for the main loop.
	var enemy_hp = 0
	var player_hp = 0
	num_of_fighters = Global.current_characters.size() + Global.current_monster_list.size()
	#print( "Fighters: ", num_of_fighters )
	
	# Total up HP from each fighter
	for i in range( Global.current_characters.size() ):
		player_hp += Global.current_characters[i]['current_hp']
	for i in range( Global.current_monster_list.size() ):
		enemy_hp = enemy_hp + int( Global.all_monsters[ Global.current_monster_list[i] ]["current_hp"] )
	
	
	while enemy_hp > 0 and player_hp > 0:
		# basically conduct this loop until one of the sides has lost.
		# this loop is for a round.
		# within a single round, we probably call two other functions. One for a character (wait for input), and one for a monster
		# MAYBE INSTEAD OF DOING THIS IN A WHILE LOOP, WE SOMEHOW USE VARIABLES TO KEEP TRACK OF WHAT'S HAPPENING.
		# AND USE THE func _process(delta): function to make sure it's always running everything.
		var now_serving = num_of_fighters 
		for i in range( num_of_fighters ):
			# Loop through each fighter and allow them to conduct their turn.
			# Start with the one with the hightest "combat_order"
			for j in range( Global.current_characters.size() ):
				if Global.current_characters[ j ]["combat_order"] == now_serving:
					# found the character whose turn it is.
					#print( "It's ", get_parent().current_characters[j]["name"], "'s Turn" )
					active_character = Global.current_characters[j]
					commentary.text = commentary.text + "\nIt's " + active_character["name"] + "'s Turn"
					
					for x in range( Global.current_characters.size() ):  # Clear previous selections
						var char_node = get_node("./M/V/H/Characters/Character" + str(x) + "/BG")
						char_node.texture = null
					# Add new selection.
					var char_node = get_node("./M/V/H/Characters/Character" + str(j) + "/BG")
					char_node.texture = selected_box
					
					
					# Allow the Player to tell their character what to do.
					yield(self, "turn_completed")
					
					# ALLOW THE CHARACTER TO DO IT'S TURN
					# POP UP IT'S PANEL WITH COMMANDS, HAND OFF PROCESS TO IT USING THE YIELD() FUNCTION
					# WAIT FOR SIGNAL BACK TO CONTINUE WITH THIS.
					#pass
			for j in range( Global.current_monster_list.size() ):
				if Global.all_monsters[ Global.current_monster_list[j] ]["combat_order"] == now_serving:
					#print("It's ", monsters[ monster_list[j] ]['name'], "'s Turn" )
					commentary.text = commentary.text + "\nIt's " + Global.all_monsters[ Global.current_monster_list[j] ]['name'] + "'s Turn"
					#print(monsters[ monster_list[j] ]['name'], " attacked!")
					commentary.text = commentary.text + "\n" + Global.all_monsters[ Global.current_monster_list[j] ]['name'] + " attacked!"
					
					# found the monster whose turn it is.
					# ALLOW THE MONSTER TO DO IT'S TURN
					# CALL THE MONSTER PLAY FUNCTION WITH YIELD() FUNCTION
					# WAIT FOR SIGNALE BACK TO CONTINUE WITH THIS.
					pass
			now_serving -= 1
		
		# At the end, sum up the enemy_hp and the player_hp
		player_hp = 0
		enemy_hp = 0
		for i in range( Global.current_characters.size() ):
			player_hp += Global.current_characters[i]['current_hp']
		for i in range( Global.current_monster_list.size() ):
			enemy_hp = enemy_hp + Global.all_monsters[ Global.current_monster_list[i] ]["current_hp"] 
		
		print("END OF ROUND Player HP: ", player_hp, "     Enemy HP: ", enemy_hp)
		commentary.text += "\n========== End of Round =========="
		roll_initiative()
		
		if enemy_hp <= 0:
		# Player has won.
		# close everything and go to the on_win page
			print("Player has won!")
			
		
		if player_hp <= 0:
		# Player has lost.
		# close everything and go to the on_lose page
			print("Player has lost!")
			
		










func roll_initiative():
	var available_ranks = []
	var max_size
	var decreasing = true
	available_ranks.resize( Global.current_monster_list.size() + Global.current_characters.size() )
	for i in range( available_ranks.size() ):
		available_ranks[i] = int(i)
		max_size = i
	#print("Available Numbers: ", available_ranks, " Max Size: ", str(max_size) )
	
# Loop through the characters first and assign ranks.
	for i in range( Global.current_characters.size() ):
		randomize()
		var num_to_try  = randi() % available_ranks.size() # + 1
		#print( "Loop: ", i, " Random: ", num_to_try )
		num_to_try += Global.current_characters[i]["dex_bonus"]
		#print( "With bonus: ", num_to_try )
		if num_to_try > max_size:
			num_to_try = max_size
		num_to_try = int(num_to_try)
		#print( "Capped: ", str(num_to_try) )
		if !available_ranks.has( num_to_try ):
			#print( str(num_to_try), " is not available." )
			# the number to try doesn't appear in the available numbers.
			# here we need to subtract one from it and check again. We can do this up to 6 times.
			for x in range( max_size * 2 ):
				if decreasing:
					num_to_try -= 1
				else:
					num_to_try += 1
				if num_to_try < 0:
					decreasing = false
					num_to_try += 1
				if !available_ranks.has( num_to_try ):
					# the number is still not available then subtract.
					#print ( str(num_to_try), " is not available." )
					pass
				else:
					break
		available_ranks.remove( available_ranks.find( num_to_try ) )
		#print( "Final Num: ", str(num_to_try) )
		Global.current_characters[i]["combat_order"] = num_to_try
		#print("Available: ", available_ranks)

	# Loop through the monsters and assign ranks.
	for i in range( Global.current_monster_list.size() ):
		randomize()
		var num_to_try  = randi() % available_ranks.size() # + 1
		#print( "Loop: ", i, " Random: ", num_to_try )
		#num_to_try += monsters[i]["dex_bonus"]
		#print( "With bonus: ", num_to_try )
		#if num_to_try > max_size:
		#	num_to_try = max_size
		num_to_try = int(num_to_try)
		#print( "Capped: ", str(num_to_try) )
		if !available_ranks.has( num_to_try ):
			#print( str(num_to_try), " is not available." )
			# the number to try doesn't appear in the available numbers.
			# here we need to subtract one from it and check again. We can do this up to 6 times.
			decreasing = true
			for x in range( max_size * 2 ):
				if decreasing:
					num_to_try -= 1
				else:
					num_to_try += 1
				if num_to_try < 0:
					decreasing = false
					num_to_try += 1
				if !available_ranks.has( num_to_try ):
					# the number is still not available then subtract.
					#print ( str(num_to_try), " is not available." )
					pass
				else:
					break
		available_ranks.remove( available_ranks.find( num_to_try ) )
		#print( "Final Num: ", str(num_to_try) )
		Global.all_monsters[ Global.current_monster_list[i] ]["combat_order"] = num_to_try
		#print("Available: ", available_ranks)

#	# show all of the ranks
#	for i in range( get_parent().current_characters.size() ):
#		print( get_parent().current_characters[i]['name'], ": ", get_parent().current_characters[i]['combat_order'] )
#	for i in range( monsters.size() ):
#		print( monsters[i]['name'], ": ", monsters[i]['combat_order'] )
		
# show all of the ranks in order:
	max_size += 1
	var rank = int(max_size)
	for i in range(max_size):
		#print("Loop: ", str(i) )
		rank = rank - 1
		#print("Looking for Rank: ", rank)
		for x in range( Global.current_characters.size() ):
			# loop through each of the players.
			if Global.current_characters[x]['combat_order'] == rank:
				#print( get_parent().current_characters[x]['name'], ": ", get_parent().current_characters[x]['combat_order'] )
				pass
		for x in range( Global.current_monster_list.size() ):
			# loop through each of the monsters.
			if Global.all_monsters[ Global.current_monster_list[x] ]['combat_order'] == rank:
				#print( monsters[ monster_list[x] ]['name'], ": ", monsters[ monster_list[x] ]['combat_order'] )
				pass



func _on_MeleeButton_pressed():
	# THIS IS A TEMPORARY PLACE FOR THIS...EVENTUALLY THIS SHOULD BE COMING UP IN A POPUP.
	# The melee attack button is pressed:
	commentary.text += "\nMelee Attack by player."
	
	# How do we decide which monster is being attacked.
	
	var monster_ac
	var player_bonus
	
	emit_signal('turn_completed')
