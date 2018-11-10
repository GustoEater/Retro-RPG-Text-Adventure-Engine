extends NinePatchRect

var current_monster_list = []
var monsters
onready var commentary = $M/V/H2/M/Commentary


func prep_monsters(list, on_win, on_lose):
	var number_of_monsters = list.left( list.findn( ":" ) )
	list = list.right( list.findn( ":" ) + 1 )
	# remove leading \n\r\n from the beginning.
	list = list.right ( 3 )

	# separate each monster (monster_list) into our list of monsters.
	for i in range( number_of_monsters ):
		current_monster_list.append( list.left( list.findn( "\n" ) ) )
		list = list.right( current_monster_list[i].length() + 3 )
		current_monster_list[ i ] = current_monster_list[ i ].right( 1 )
		current_monster_list[ i ] = current_monster_list[ i ].left( current_monster_list[ i ].length() - 1 )
	
	# Load monsters into the monsters array.
	# load the appropriate monsters into the monsters array.
	for i in range( current_monster_list.size() ):
		#monsters.append( get_parent().all_monsters[ monster_list[ i ] ])
		monsters = get_node('/root/Game').all_monsters.duplicate()
		#print( monster_list[i] )
		#print( monsters[ monster_list[i] ] )

	# Update the "hp" for each monster using their "hit dice"
	#print( monsters.size() )
	for i in range( current_monster_list.size() ):
		var hd = monsters[ current_monster_list[i] ][ "hit_dice" ]
		#print("Hit Dice: ", hd )
		var hp = roll_dice( hd )
		#print("Hit Points: ", hp )
		monsters[ current_monster_list[i] ]["max_hp"] = hp
		if monsters[ current_monster_list[i] ].has('current_hp'):
			monsters[ current_monster_list[i] ]["current_hp"] = hp
#		print( monsters[ i ][ "current_hp" ] )
	
	# Add the Monster Information to the screen. (under "$MarginContainer/HBoxContainer/Monsters"
	# This should include a label, a picture, a health bar.


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
	for i in range( current_monster_list.size() ):
		if i < current_monster_list.size() - 2 :
			opening_message += monsters[ current_monster_list[i] ]["name"] + ", a "
		elif i < current_monster_list.size() - 1:
			opening_message += monsters[ current_monster_list[i] ]["name"] + ", and a "
		else:
			opening_message += monsters[ current_monster_list[i] ]["name"] + "."

	#print( opening_message )
	commentary.text = commentary.text + opening_message

	# Roll Initiative.
	#roll_initiative()
	#battle()