extends HBoxContainer

#var image_path
#var character_name
#var max_hp
#var current_hp
#var max_mp
#var current_mp
var my_index

#onready var character_node = get_node('/root/Game/StoryUI')



func update_ui():
	#image_path = Global.current_characters[my_index]['pic']
	$NinePatchRect/Info/M/V/Name.text = Global.all_monsters[ Global.current_monster_list[my_index] ]['name']
	$NinePatchRect/Info/M/V/Health.max_value = Global.all_monsters[ Global.current_monster_list[my_index] ]['max_hp']
	$NinePatchRect/Info/M/V/Health.value = Global.all_monsters[ Global.current_monster_list[my_index] ]['current_hp']
	
	$NinePatchRect/Image/M/Image.texture_normal = ResourceLoader.load( "res://Assets/Character/" + Global.all_monsters[ Global.current_monster_list[ my_index ] ].pic )
	
	
	
#	$NinePatchRect/Info/M/V/Magic.max_value = Global.all_monsters[ Global.current_monster_list[my_index] ]['max_mp']
#	$NinePatchRect/Info/M/V/Magic.value = Global.all_monsters[ Global.current_monster_list[my_index] ]['current_mp']
	
#	$NinePatchRect/Info/M/V/Name.text = character_name
#	$NinePatchRect/Info/M/V/Magic.max_value = max_mp
#	$NinePatchRect/Info/M/V/Magic.value = current_mp
#	$NinePatchRect/Info/M/V/Health.max_value = max_hp
#	$NinePatchRect/Info/M/V/Health.value = current_hp
