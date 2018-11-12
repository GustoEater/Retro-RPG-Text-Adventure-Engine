extends HBoxContainer

var monster_data = {}
#var image_path
#var monster_name
#var max_hp
#var current_hp
#var ac
#var combat_order
#var attack_bonus
#var xp
#var num_of_attacks
#var attacks = []
#var damage = []
#var max_mp
#var current_mp
var my_index
var selected = false

# NOTE: ALL DATA USED DURING THE BATTLE SHOULD RESIDE IN THIS NODE RATHER THAN USING THE DATA IN Global.current_monster_list, etc.



func update_ui(full):
	#print( monster_data )
	if full:
		$NinePatchRect/Info/M/V/Name.text = monster_data.name
		$NinePatchRect/Info/M/V/Health.max_value = monster_data.max_hp
		$NinePatchRect/Info/M/V/Health.value = monster_data.current_hp
		$NinePatchRect/Image/M/Image.texture_normal = ResourceLoader.load( "res://Assets/Character/" + monster_data.pic )
		#image_path = Global.current_characters[my_index]['pic']
		#$NinePatchRect/Info/M/V/Name.text = Global.all_monsters[ Global.current_monster_list[my_index] ]['name']
		#$NinePatchRect/Info/M/V/Health.max_value = Global.all_monsters[ Global.current_monster_list[my_index] ]['max_hp']
		#$NinePatchRect/Image/M/Image.texture_normal = ResourceLoader.load( "res://Assets/Character/" + Global.all_monsters[ Global.current_monster_list[ my_index ] ].pic )
		#$NinePatchRect/Info/M/V/Health.value = Global.all_monsters[ Global.current_monster_list[my_index] ]['current_hp']
		if selected:
			$Selected.visible = true
		else:
			$Selected.visible = false
	else:
		$NinePatchRect/Info/M/V/Health.value = monster_data.current_hp
		#$NinePatchRect/Info/M/V/Health.value = Global.all_monsters[ Global.current_monster_list[my_index] ]['current_hp']
		if selected:
			$Selected.visible = true
		else:
			$Selected.visible = false
	
	
	
	
#	$NinePatchRect/Info/M/V/Magic.max_value = Global.all_monsters[ Global.current_monster_list[my_index] ]['max_mp']
#	$NinePatchRect/Info/M/V/Magic.value = Global.all_monsters[ Global.current_monster_list[my_index] ]['current_mp']
	
#	$NinePatchRect/Info/M/V/Name.text = character_name
#	$NinePatchRect/Info/M/V/Magic.max_value = max_mp
#	$NinePatchRect/Info/M/V/Magic.value = current_mp
#	$NinePatchRect/Info/M/V/Health.max_value = max_hp
#	$NinePatchRect/Info/M/V/Health.value = current_hp


func _on_Name_pressed():
	# When the name is pressed, the Monster is selected and all other monsters are unselected.
	
	# Clear all selections from monsters.
	#var monsters = get_node('/root/Game/CombatUI/M/V/H/Monsters').get_children()
	var monsters = self.get_parent().get_children()
	for monster in monsters:
		monster.selected = false
		monster.update_ui(false)
	get_node('/root/Game/CombatUI').selected_monster = my_index
	selected = true
	update_ui(false)