extends Node

export ( String, FILE, '*.json' ) var current_characters_to_load = 'res://Data/Characters.JSON'
export ( String, FILE, '*.json' ) var available_characters_to_load = ''
export ( String, FILE, '*.json' ) var all_monsters_to_load = 'res://Data/Monsters.JSON'
export ( String, FILE, '*.json' ) var adventure = 'res://Data/The_Fairhaven_Incident.JSON'

var current_characters = []
var all_monsters = {}
var current_monster_list = []

var full_adventure = {}
var passages = []  # The array of 'pages' (called 'passages' by Twine)


func _ready():
# Load the current characters.
	var file = File.new()
	file.open( current_characters_to_load, file.READ )
	var full_file_text = file.get_as_text()
	file.close()

	var full_file_parse = JSON.parse( full_file_text )
	if full_file_parse.error == OK:  # If the JSON file was okay, then process it.
		current_characters = full_file_parse.result
	else:  # If there is an error in the JSON file, then deal with it.
		print( 'Characters: ', full_file_parse.error_line, ', ', full_file_parse.error_string )

# Load the full monster list.
	file = File.new()
	file.open( all_monsters_to_load, file.READ )
	full_file_text = file.get_as_text()
	file.close()

	full_file_parse = JSON.parse( full_file_text )
	if full_file_parse.error == OK:  # If the JSON file was okay, then process it.
		all_monsters = full_file_parse.result
	else:  # If there is an error in the JSON file, then deal with it.
		print( 'Monsters: ', full_file_parse.error_line, ', ', full_file_parse.error_string )

# Load the Adventure (Twine to JSON format)
	file = File.new()
	file.open( adventure, file.READ )
	full_file_text = file.get_as_text()
	file.close()

	full_file_parse = JSON.parse( full_file_text )
	if full_file_parse.error == OK:  # If the JSON file was okay, then process it.
		full_adventure = full_file_parse.result
	else:  # If there is an error in the JSON file, then deal with it.
		print( 'Adventure: ', full_file_parse.error_line, ', ', full_file_parse.error_string )
	
	passages = full_adventure.passages




# Add Scenes to the Tree
	var scene = load('res://Scenes/StoryUI.tscn')
	var scene_instance = scene.instance()
	scene_instance.set_name( 'StoryUI' )
	scene_instance.hide()
	get_node('/root/Game').add_child(scene_instance)
	get_node('/root/Game').get_node('StoryUI').update_page(1)  # Sending 1 because Twine starts at 1.
	
	scene = load('res://Scenes/CombatUI.tscn')
	scene_instance = scene.instance()
	scene_instance.set_name( 'CombatUI' )
	scene_instance.hide()
	get_node('/root/Game').add_child(scene_instance)


func roll_dice( string ):
#	This function takes an input string like "1d6+1" and rolls the appropriate dice.
	var sum = 0
#	Parse the string.
	if string.findn( '+' ) == -1:
		var number = int( string.left( string.findn( 'd' ) ) )
		var type = int( string.right( string.length() - ( str(number).length() + 1) ) )
		for i in range( number ):
			randomize()
			sum += randi() % type + 1
		return sum
	elif string.findn( '+' ) > -1:
		# There is a bonus at the end.
		#print( 'Rolling: ', string )
		var number = int( string.left( string.findn( 'd' ) ) )   # int( string.left( 1 ) = 1
		#print( 'Rolling number: ', number )
		var remainder = string.right( string.find( 'd' ) )  # string.right( 5 - 1+1 ) right(3) = 6+1
		#print( 'Rolling remainder (1): ', remainder )
		var type = int( remainder.left( remainder.findn( '+' ) ) )   # int( string.left( 1 ) = 6
		#print( 'Rolling type: ', type )
		var bonus = int( remainder.right( remainder.length() - ( str(type).length() + 1) ) )
		#print( 'Rolling bonus: ', bonus )
		for i in range( number ):
			randomize()
			sum += randi() % type + 1
		sum += bonus
		return sum
