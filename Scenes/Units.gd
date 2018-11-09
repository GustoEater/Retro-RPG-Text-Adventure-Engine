extends Node

export ( String, FILE, "*.json" ) var characters_to_load = "res://Data/Characters.JSON"
export ( String, FILE, "*.json" ) var opt_characters_to_load = ""
var opt_characters = []
var characters = []


func _ready():
	# Load the full character list. This will be all the pre-made characters and the custom ones made
	# opens the file and reads the text into the "full_file_text" variable.
	var file = File.new()
	file.open( characters_to_load, file.READ )
	var full_file_text = file.get_as_text()
	file.close()
	# read the "full_file_text" information as a JSON file.
	var full_file_parse = JSON.parse( full_file_text )
	if full_file_parse.error == OK:  # If the JSON file was okay, then process it.
		characters = full_file_parse.result
	else:  # If there is an error in the JSON file, then deal with it.
		print( "Characters ERROR: ", full_file_parse.error_line, ", ", full_file_parse.error_string )
			
	# THIS STUFF SHOULD PROBABLY BE IN THE GAME NODE SCRIPT (OR THE CHARACTERS NODE SCRIPT)
	# Load the characters into new character nodes and add them as children of "Characters"
	var scene = load("res://Scenes/CharacterNew.tscn")
	for i in range( characters.size() ):
		var instance = scene.instance()
		instance.set_name( characters[i]['name'])
		$Characters.add_child(instance)
		var char_node = $Characters.get_node( characters[i]['name'] )
		char_node.get_node('Stats').import_from_dict( characters[i] )
		char_node.initialize()
		
	
	# load the variable info.
	