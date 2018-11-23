extends HBoxContainer

var monster_data = {}
var my_index
var selected = false
var active = true
var enabled = true

onready var selected_box = ResourceLoader.load('res://Assets/GUI/SelectedBox.png')
onready var disabled_box = ResourceLoader.load('res://Assets/GUI/DisabledBox.png')

func disable():	# This status means the monster is dead.
	$BG.texture = disabled_box
	$BG/Info/M/V/Name.disabled = true


func enable():	# This status means the monster is not dead.
	$BG.texture = null
	$BG/Info/M/V/Name.disabled = false


func update_ui(full_update):
	if full_update:
		$BG/Info/M/V/Name.text = monster_data.name
		$BG/Info/M/V/Health.max_value = monster_data.max_hp
		$BG/Image/M/Image.texture_normal = ResourceLoader.load( 'res://Assets/Character/' + monster_data.pic )
	$BG/Info/M/V/Health.value = monster_data.current_hp
	if selected:
		$Selected.visible = true
	else:
		$Selected.visible = false
	if active: # show the green selected_box
		$BG.texture = selected_box
		$BG/Info/M/V/Name.disabled = false
	else: # don't show the green selected_box
		$BG.texture = null
	if enabled:
		enable()
	else:
		disable()


func _on_Name_pressed():
	# When the name is pressed, the Monster is selected and all other monsters are unselected.
	var monsters = self.get_parent().get_children()
	for monster in monsters:
		monster.selected = false
		monster.update_ui(false)
	get_node('/root/Game/CombatUI').selected_monster = my_index
	selected = true
	update_ui(false)