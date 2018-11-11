extends HBoxContainer

#var image_path
#var character_name
#var max_hp
#var current_hp
#var max_mp
#var current_mp
var my_index

#onready var character_node = get_node('/root/Game/StoryUI')
#onready var monster_node = preload("res://Scenes/CombatUI.tscn")


func update_ui():
	#image_path = Global.current_characters[my_index]['pic']
	$BG/Info/M/V/Name.text = Global.current_characters[my_index]['name']
	$BG/Info/M/V/Health.max_value = Global.current_characters[my_index]['max_hp']
	$BG/Info/M/V/Health.value = Global.current_characters[my_index]['current_hp']
	$BG/Info/M/V/Magic.max_value = Global.current_characters[my_index]['max_mp']
	$BG/Info/M/V/Magic.value = Global.current_characters[my_index]['current_mp']
	$BG/Image/M/Image.texture_normal = load("res://Assets/Character/" + Global.current_characters[my_index].pic)
	#print("res://Assets/Character/" + Global.current_characters[my_index].pic)
	
#	var image.append(Image.new())
#	image.load("res://Assets/Character/" + Global.current_characters[my_index].pic)
#	var texture.append(ImageTexture.new())
#	texture.create_from_image(image)
#	$NinePatchRect/Info/M/V/Name.text = character_name
#	$NinePatchRect/Info/M/V/Magic.max_value = max_mp
#	$NinePatchRect/Info/M/V/Magic.value = current_mp
#	$NinePatchRect/Info/M/V/Health.max_value = max_hp
#	$NinePatchRect/Info/M/V/Health.value = current_hp
