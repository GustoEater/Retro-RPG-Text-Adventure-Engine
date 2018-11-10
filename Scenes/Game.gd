extends Node



#export ( String, FILE, "*.json" ) var adventure_to_load = "res://Data/AdventureParsed.JSON"
export ( String, FILE, "*.json" ) var current_characters_to_load = "res://Data/Characters.JSON"
export ( String, FILE, "*.json" ) var available_characters_to_load = ""
export ( String, FILE, "*.json" ) var all_monsters_to_load = "res://Data/Monsters.JSON"

#export var full_adventure = {}
var current_characters = []
var all_monsters = {}




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
		print( "Characters: ", full_file_parse.error_line, ", ", full_file_parse.error_string )

# Load the full monster list.
	file = File.new()
	file.open( all_monsters_to_load, file.READ )
	full_file_text = file.get_as_text()
	file.close()

	full_file_parse = JSON.parse( full_file_text )
	if full_file_parse.error == OK:  # If the JSON file was okay, then process it.
		all_monsters = full_file_parse.result
	else:  # If there is an error in the JSON file, then deal with it.
		print( "Monsters: ", full_file_parse.error_line, ", ", full_file_parse.error_string )




