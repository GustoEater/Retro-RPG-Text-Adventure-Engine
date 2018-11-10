extends HBoxContainer

var image_path
var character_name
var max_hp
var current_hp
var max_mp
var current_mp
var my_index

onready var character_node = get_node('/root/Game/StoryUI')



func update_ui():
	image_path = character_node.current_characters[my_index]['pic']
	character_name = character_node.current_characters[my_index]['name']
	max_hp = character_node.current_characters[my_index]['max_hp']
	current_hp = character_node.current_characters[my_index]['current_hp']
	max_mp = character_node.current_characters[my_index]['max_mp']
	current_mp = character_node.current_characters[my_index]['current_mp']
	
	print("Updating UI on Characters")
	$NinePatchRect/Info/M/V/Name.text = character_name
	$NinePatchRect/Info/M/V/Magic.max_value = max_mp
	$NinePatchRect/Info/M/V/Magic.value = current_mp
	$NinePatchRect/Info/M/V/Health.max_value = max_hp
	$NinePatchRect/Info/M/V/Health.value = current_hp
