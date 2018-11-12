extends NinePatchRect

#var current_monster_list = []
#export var monsters = {}
onready var commentary = $M/V/H2/BG/M/Commentary

var num_of_fighters
var active_character
var active_monster
var selected_character
var selected_monster

onready var selected_box = ResourceLoader.load("res://Assets/GUI/SelectedBox.png")

signal turn_completed
signal end_combat




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
		new_node.update_ui(true)





func prep_monsters(list, on_win, on_lose):
# Parse the list of monsters and add to Global.current_monster_list array.
	var number_of_monsters = list.left( list.findn( ":" ) )
	list = list.right( list.findn( ":" ) + 1 )
	list = list.right ( 3 )   # remove leading \n\r\n from the beginning.
	for i in range( number_of_monsters ):
		Global.current_monster_list.append( list.left( list.findn( "\n" ) ) )
		list = list.right( Global.current_monster_list[i].length() + 3 )
		Global.current_monster_list[ i ] = Global.current_monster_list[ i ].right( 1 )
		Global.current_monster_list[ i ] = Global.current_monster_list[ i ].left( Global.current_monster_list[ i ].length() - 1 )
#	From the monster's hit_dice, calculate their max_hp
	for i in range( Global.current_monster_list.size() ):
		var hd = Global.all_monsters[ Global.current_monster_list[i] ][ "hit_dice" ]
		var hp = roll_dice( hd )
		Global.all_monsters[ Global.current_monster_list[i] ]["max_hp"] = hp
		if Global.all_monsters[ Global.current_monster_list[i] ].has('current_hp'):
			Global.all_monsters[ Global.current_monster_list[i] ]["current_hp"] = hp
#	Add MonsterUI information.
	var target_parent_node = $M/V/H/Monsters
	for i in range( Global.current_monster_list.size() ):
		var scene = load("res://Scenes/MonsterUI.tscn")
		var scene_instance = scene.instance()
		scene_instance.set_name( 'Monster' + str(i) )
		target_parent_node.add_child(scene_instance)
		var new_node = target_parent_node.get_child(i)
		# Fill in the data on the new node with info from monster.
		new_node.monster_data = Global.all_monsters[ Global.current_monster_list[i] ]
		new_node.my_index = i
#	The first monster should be selected (all others should not be selected)
		if i == 0:
			selected_monster = 0
			new_node.selected = true
#	Update the user interface (true = a full update)
		new_node.update_ui(true)




func roll_dice( string ):
	# This function takes an input string like "1d6" and rolls the appropriate dice.
	# Parse the string.
	var sum = 0
	var number = int( string.left( string.findn( "d" ) ) )
	var type = int( string.right( string.length() - ( str(number).length() + 1) ) )
	for i in range( number ):
		randomize()
		sum += randi() % type + 1
	return sum




func start():
#	Sets up the beginning of combat.
	var opening_message = "You are fighting a "
	var num_of_monsters = $M/V/H/Monsters.get_child_count()
	for i in range( num_of_monsters ):  # Shows what monsters are attacking.
		if i < num_of_monsters - 2 :
			opening_message += $M/V/H/Monsters.get_child(i).monster_data['name'] + ", a "
		elif i < num_of_monsters - 1:
			opening_message += $M/V/H/Monsters.get_child(i).monster_data['name'] + ", and a "
		else:
			opening_message += $M/V/H/Monsters.get_child(i).monster_data['name'] + ".\n"
	commentary.text = commentary.text + opening_message
#	Roll Initiative.
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
					$M/V/H/Commands/MeleeButton.disabled = false
				# Highlight the current character.
					for x in range( Global.current_characters.size() ):  # Clear previous selections
						var char_node = get_node("./M/V/H/Characters/Character" + str(x) + "/BG")
						char_node.texture = null
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
	#available_ranks.resize( Global.current_monster_list.size() + Global.current_characters.size() )
	available_ranks.resize( $M/V/H/Monsters.get_child_count() + Global.current_characters.size() )
	for i in range( available_ranks.size() ):
		available_ranks[i] = int(i)
		max_size = i
#	Loop through the characters first and assign ranks.
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

#	Loop through the monsters and assign ranks.
	#for i in range( Global.current_monster_list.size() ):
	for i in range( $M/V/H/Monsters.get_child_count() ):
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
		#Global.all_monsters[ Global.current_monster_list[i] ]["combat_order"] = num_to_try
		$M/V/H/Monsters.get_child(i).monster_data['combat_order'] = num_to_try
		#print("Available: ", available_ranks)

#	# show all of the ranks
#	for i in range( get_parent().current_characters.size() ):
#		print( get_parent().current_characters[i]['name'], ": ", get_parent().current_characters[i]['combat_order'] )
#	for i in range( monsters.size() ):
#		print( monsters[i]['name'], ": ", monsters[i]['combat_order'] )
		
#	Show all of the ranks in order:
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
		for x in range( $M/V/H/Monsters.get_child_count() ):
			# loop through each of the monsters.
			#if Global.all_monsters[ Global.current_monster_list[x] ]['combat_order'] == rank:
			if $M/V/H/Monsters.get_child(x).monster_data['combat_order'] == rank:
				#print( monsters[ monster_list[x] ]['name'], ": ", monsters[ monster_list[x] ]['combat_order'] )
				pass


# ==============================================================================================
# WORKING HERE. NEED TO UPDATE BATTLE AND _ON_MELEEBUTTON_PRESSED FUNCTIONS TO RELY ON THE DATA
# IN THE MONSTERS NODES INSTEAD OF THE GLOBAL VARIABLES.
# ==============================================================================================

func _on_MeleeButton_pressed():
	$M/V/H/Commands/MeleeButton.disabled = true
	var selected_monster_data = Global.all_monsters[ Global.current_monster_list[ selected_monster ] ]
	var selected_monster_node = get_node('M/V/H/Monsters/Monster' + str(selected_monster) )
	var monsters_node = get_node('M/V/H/Monsters')
	var monster_ac = Global.all_monsters[ Global.current_monster_list[ selected_monster ] ].ac
	var message = "\n"
	var critical_hit = false
	var critical_miss = false
	var attack_roll = roll_dice('1d20')
	if attack_roll == 20:
		critical_hit = true
		message += "CRITICAL HIT! Double damage.\n"
	if attack_roll == 1:
		critical_miss = true
		message += "CRITIICAL MISS!\n"
		attack_roll = -10
	attack_roll += active_character.attack_bonus + active_character.str_bonus
	if attack_roll >= monster_ac or critical_hit:
		message = active_character.name + " hit " + selected_monster_data.name + " with a roll of " + str(attack_roll) + "."
		var damage = roll_dice('1d8')
		if critical_hit:
			damage = damage * 2
		message += "\n" + selected_monster_data.name + " took " + str(damage) + " sword damage." 
		selected_monster_data.current_hp -= damage
		if selected_monster_data.current_hp <= 0:
			# monster has been killed. What do we do?
			selected_monster_data.current_hp = 0
			if $M/V/H/Monsters.get_child_count() == 1:
				# No more monsters...players have won!!
				message = "You won!"
				emit_signal('end_combat')
			else:
				# WHICH MONSTER GOT KILLED? "Monster + str(selected_monster) is the one that got killed.
				selected_monster_data.selected = false
				selected_monster_node.get_parent().remove_child(selected_monster_node)
				var remaining_monsters = monsters_node.get_children()
				remaining_monsters[0].selected = true
				Global.current_monster_list.remove(selected_monster)
				#get_node('M/V/H/Monsters/' + remaining_monsters[0].name).selected = true
				print("All: ", remaining_monsters, "  Just [0]: ", remaining_monsters[0].name)
				print(remaining_monsters[0].name, " is now selected: ", remaining_monsters[0].selected)
				remaining_monsters[0].update_ui(false)
		else:
			selected_monster_node.update_ui(false)
	else:
		message = active_character.name + " missed " + selected_monster_data.name + " with a roll of " + str(attack_roll) + "."
	commentary.text += message
	
		
	emit_signal('turn_completed')
