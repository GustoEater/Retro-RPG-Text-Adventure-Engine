extends Node

# The intent of the Narrative Scene is to load the data from a JSON file into a dictionary which will then feed
#      the text box for the adventure as well as figuring out the choices and where the text goes from the choice.

var all_pages_dict = {}
var target_page_dict = {}



func _ready():
	# will probably move this somewhere else but just for testing purposes, this should be good.
	
	var file = File.new()
	file.open("res://Data/Test1.JSON", file.READ)
	var file_text = file.get_as_text()
	file.close()
	
	var data_parse = JSON.parse(file_text)
	if data_parse.error == OK:
		# If the JSON file was okay, then you can process it.
		all_pages_dict = data_parse.result
		# Here we want to read "page-one" so we'll store "page-one" into "target_page_dict"
		target_page_dict = all_pages_dict["page-one"]
		# If it workks, we'll put the "narrative" key value into the text box on screen
		var game_text_node = get_parent().get_node("Text")
		#game_text_node.get("custom_fonts/font").set_size(100)
		game_text_node.text = target_page_dict["narrative"]
		
	else:  # If there is an error in the JSON file, then deal with it.
		print (data_parse.error_line, ", ", data_parse.error_string)
	
	
	
	
#	print (text)
#	if data_parse.error == OK:
#		DataDictionary = data_parse.result
#		game_text_node.text = DataDictionary["page-two"]
#		print (DataDictionary["page-two"])
#	else:
#		print (data_parse.error_line, ", ", data_parse.error_string)
		
	#print (DataDictionary.map)

