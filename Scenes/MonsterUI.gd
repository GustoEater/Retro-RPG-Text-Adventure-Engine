extends HBoxContainer

var monster_data = {}
var my_index
var selected = false


func update_ui(full):
	if full:
		$NinePatchRect/Info/M/V/Name.text = monster_data.name
		$NinePatchRect/Info/M/V/Health.max_value = monster_data.max_hp
		$NinePatchRect/Image/M/Image.texture_normal = ResourceLoader.load( 'res://Assets/Character/' + monster_data.pic )
	$NinePatchRect/Info/M/V/Health.value = monster_data.current_hp
	if selected:
		$Selected.visible = true
	else:
		$Selected.visible = false


func _on_Name_pressed():
	# When the name is pressed, the Monster is selected and all other monsters are unselected.
	var monsters = self.get_parent().get_children()
	for monster in monsters:
		monster.selected = false
		monster.update_ui(false)
	get_node('/root/Game/CombatUI').selected_monster = my_index
	selected = true
	update_ui(false)