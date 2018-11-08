extends PopupPanel

# HOW COMBAT WORKS:
	# 1) Check for surprise. (NEED TO PASS WHETHER SURPRISE IS POSSIBLE FROM THE STORY.
		# For surprise, you check each side that could be surprised and roll 1d6. Normal characters are surprised on 1-2.
		# Elves (and some creatures) are less likely to be surprised. They would be only on a roll of 1.
		# Surprised characters lose the first round.
	# 2) Roll initiative.
		# Each round, initiative is rolled. 1d6 adjusted by the character/monster's Dexterity Bonus. High numbers act first.
		# This is the order in which the actions are taken. 
	# 3) On a character's turn, they may:
		# a) Attack
			# Weapons:
			# Roll "To Hit": Roll 1d20 and add attack_bonus and STR bonus (if melee) or DEX bonus (if range)
			# If the total is equal to or greater than the opponents Armor Class, the attack hits and damage is rolled.
			# A natural 1 always fails. A natural 20 always hits
				# Roll "Damage": Damage is rolled per the weapon used.
			# Spells:
			# 
		# b) Defend
			# Making this up. If the character defends, their AC increases by 1d8 (thus they are less likely to be hit)
		# c) Retreat
			# Not sure if this should be allowed since we're story based. I think they have to fight when there is a monster.
			
# INFORMATION NEEDED FOR COMBAT:
	# LIST OF MONSTERS THAT ARE ATTACKING
	# WHETHER THE PARTY OR THE MONSTERS CAN BE SURPRISED
	# ALL DATA FOR EACH MONSTER (AC, ATTACK BONUS, WEAPON, STR, DEX)
	# HOW MUCH XP IS RECEIVED WHEN THE MONSTERS ARE DEFEATED
	# IF THERE IS ANY TREASURE TO BE RECEIVED.
	
	
var current_character
var current_monster

var monsters = {}
var monster_list_text
var monster_data = {}
var monster_list = []

var num_of_fighters

var on_win
var on_lose





func _ready():
	roll_dice( "2d6" )



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
	
	
	
	
	



	
	
func prep_monsters():
	#var m_list = []
	# remove leading /r/n THIS WAS REMOVED BECAUSE I PREVENTED THE JSON FILE FROM STARTING WITH \R\N.
	#monster_list_text = monster_list_text.right( 2 )
	# get count of monsters

	var number_of_monsters = monster_list_text.left( monster_list_text.findn( ":" ) )
	monster_list_text = monster_list_text.right( monster_list_text.findn( ":" ) + 1 )
	# remove leading \n\r\n from the beginning.
	monster_list_text = monster_list_text.right ( 3 )

	# separate each monster (monster_list) into our list of monsters.
	for i in range( number_of_monsters ):
		monster_list.append( monster_list_text.left( monster_list_text.findn( "\n" ) ) )
		monster_list_text = monster_list_text.right( monster_list[i].length() + 3 )
		monster_list[ i ] = monster_list[ i ].right( 1 )
		monster_list[ i ] = monster_list[ i ].left( monster_list[ i ].length() - 1 )
	
	# Load monsters into the monsters array.
	#var main = get_parent()
	# load the appropriate monsters into the monsters array.
	for i in range( monster_list.size() ):
		#monsters.append( get_parent().all_monsters[ monster_list[ i ] ])
		monsters = get_parent().all_monsters.duplicate()
		print( monster_list[i] )
		print( monsters[ monster_list[i] ] )

	# Update the "hp" for each monster using their "hit dice"
	print( monsters.size() )
	for i in range( monster_list.size() ):
		var hd = monsters[ monster_list[i] ][ "hit_dice" ]
		print("Hit Dice: ", hd )
		var hp = roll_dice( hd )
		print("Hit Points: ", hp )
		monsters[ monster_list[i] ]["max_hp"] = hp
		if monsters[ monster_list[i] ].has('current_hp'):
			monsters[ monster_list[i] ]["current_hp"] = hp
#		print( monsters[ i ][ "current_hp" ] )


func start():
	# This function is called just after showing the popup. It begins the combat loop.
	var opening_message = "You are fighting a "
	for i in range( monster_list.size() ):
		if i < monster_list.size() - 2 :
			opening_message += monsters[ monster_list[i] ]["name"] + ", a "
		elif i < monster_list.size() - 1:
			opening_message += monsters[ monster_list[i] ]["name"] + ", and a "
		else:
			opening_message += monsters[ monster_list[i] ]["name"] + "."

	print( opening_message )

	# Roll Initiative.
	roll_initiative()
	battle()


func battle():
	# function for the main loop.
	var enemy_hp = 0
	var player_hp = 0
	num_of_fighters = get_parent().current_characters.size() + monster_list.size()
	#print( "Fighters: ", num_of_fighters )
	
	# Total up HP from each fighter
	for i in range( get_parent().current_characters.size() ):
		player_hp += get_parent().current_characters[i]['current_hp']
	for i in range( monster_list.size() ):
		enemy_hp = enemy_hp + int( monsters[ monster_list[i] ]["current_hp"] )
	
	while enemy_hp > 0 and player_hp > 0:
		# basically conduct this loop until one of the sides has lost.
		# this loop is for a round.
		# within a single round, we probably call two other functions. One for a character (wait for input), and one for a monster
		# MAYBE INSTEAD OF DOING THIS IN A WHILE LOOP, WE SOMEHOW USE VARIABLES TO KEEP TRACK OF WHAT'S HAPPENING.
		# AND USE THE func _process(delta): function to make sure it's always running everything.
		var now_serving = num_of_fighters - 1
		for i in range( num_of_fighters ):
			# Loop through each fighter and allow them to conduct their turn.
			# Start with the one with the hightest "combat_order"
			for j in range( get_parent().current_characters.size() ):
				if get_parent().current_characters[ j ]["combat_order"] == now_serving:
					# found the character whose turn it is.
					print( "It's ", get_parent().current_characters[j]["name"], "'s Turn" )
					var target_player = get_parent().current_characters[j]
					yield($Combat.player_turn(target_player), "completed")
					
					# ALLOW THE CHARACTER TO DO IT'S TURN
					# POP UP IT'S PANEL WITH COMMANDS, HAND OFF PROCESS TO IT USING THE YIELD() FUNCTION
					# WAIT FOR SIGNAL BACK TO CONTINUE WITH THIS.
					pass
			for j in range( monster_list.size() ):
				if monsters[ monster_list[j] ]["combat_order"] == now_serving:
					# found the monster whose turn it is.
					# ALLOW THE MONSTER TO DO IT'S TURN
					# CALL THE MONSTER PLAY FUNCTION WITH YIELD() FUNCTION
					# WAIT FOR SIGNALE BACK TO CONTINUE WITH THIS.
					pass
			now_serving -= 1
		
		# At the end, sum up the enemy_hp and the player_hp
		for i in range( get_parent().current_characters.size() ):
			player_hp += get_parent().current_characters[i]['current_hp']
		for i in range( monster_list.size() ):
			enemy_hp = enemy_hp + monsters[ monster_list[i] ]["current_hp"] 
		
		if enemy_hp <= 0:
		# Player has won.
		# close everything and go to the on_win page
			print("Player has won!")
			
		
		if player_hp <= 0:
		# Player has lost.
		# close everything and go to the on_lose page
			print("Player has lost!")
			
		



func player_turn(target_player):
	print( "It's ", target_player['name'], "'s turn." )
	








func roll_initiative():
	# Roll Initiative.
	var available_ranks = []
	var max_size
	var decreasing = true
	available_ranks.resize( monsters.size() + get_parent().current_characters.size() )
	for i in range( available_ranks.size() ):
		available_ranks[i] = int(i)
		max_size = i
	print("Available Numbers: ", available_ranks, "Max Size: ", str(max_size) )
	
	# Loop through the characters first and assign ranks.
	for i in range( get_parent().current_characters.size() ):
		randomize()
		var num_to_try  = randi() % available_ranks.size() # + 1
		print( "Loop: ", i, " Random: ", num_to_try )
		num_to_try += get_parent().current_characters[i]["dex_bonus"]
		print( "With bonus: ", num_to_try )
		if num_to_try > max_size:
			num_to_try = max_size
		num_to_try = int(num_to_try)
		print( "Capped: ", str(num_to_try) )
		if !available_ranks.has( num_to_try ):
			print( str(num_to_try), " is not available." )
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
					print ( str(num_to_try), " is not available." )
					pass
				else:
					break
		available_ranks.remove( available_ranks.find( num_to_try ) )
		print( "Final Num: ", str(num_to_try) )
		get_parent().current_characters[i]["combat_order"] = num_to_try
		print("Available: ", available_ranks)

	# Loop through the monsters and assign ranks.
	for i in range( monster_list.size() ):
		randomize()
		var num_to_try  = randi() % available_ranks.size() # + 1
		print( "Loop: ", i, " Random: ", num_to_try )
		#num_to_try += monsters[i]["dex_bonus"]
		#print( "With bonus: ", num_to_try )
		#if num_to_try > max_size:
		#	num_to_try = max_size
		num_to_try = int(num_to_try)
		#print( "Capped: ", str(num_to_try) )
		if !available_ranks.has( num_to_try ):
			print( str(num_to_try), " is not available." )
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
					print ( str(num_to_try), " is not available." )
					pass
				else:
					break
		available_ranks.remove( available_ranks.find( num_to_try ) )
		print( "Final Num: ", str(num_to_try) )
		monsters[ monster_list[i] ]["combat_order"] = num_to_try
		print("Available: ", available_ranks)

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
		for x in range( get_parent().current_characters.size() ):
			# loop through each of the players.
			if get_parent().current_characters[x]['combat_order'] == rank:
				print( get_parent().current_characters[x]['name'], ": ", get_parent().current_characters[x]['combat_order'] )
		for x in range( monster_list.size() ):
			# loop through each of the monsters.
			if monsters[ monster_list[x] ]['combat_order'] == rank:
				print( monsters[ monster_list[x] ]['name'], ": ", monsters[ monster_list[x] ]['combat_order'] )


func next_player_by_index(index):
	pass
