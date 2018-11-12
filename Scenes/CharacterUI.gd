extends HBoxContainer

var char_data = {}
var my_index
var selected = false

# NOTE: ALL DATA USED DURING THE BATTLE SHOULD RESIDE IN THIS NODE RATHER THAN USING THE DATA IN Global.current_monster_list, etc.


func update_ui(full):
	if full:
		$BG/Info/M/V/Name.text = char_data['name']
		$BG/Info/M/V/Health.max_value = char_data['max_hp']
		#$BG/Info/M/V/Health.value = char_data['current_hp']
		$BG/Info/M/V/Magic.max_value = char_data['max_mp']
		#$BG/Info/M/V/Magic.value = char_data['current_mp']
		$BG/Image/M/Image.texture_normal = load("res://Assets/Character/" + char_data.pic)
	$BG/Info/M/V/Health.value = char_data['current_hp']
	$BG/Info/M/V/Magic.value = char_data['current_mp']
	if selected:
		$Selected.show()
	else:
		$Selected.hide()

