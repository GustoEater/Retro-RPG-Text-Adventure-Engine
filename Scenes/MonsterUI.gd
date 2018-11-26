extends HBoxContainer

var monster_data = {}
var my_index
var selected = false
#var active = true
var enabled = true

onready var selected_box = ResourceLoader.load('res://Assets/GUI/SelectedBox.png')
onready var disabled_box = ResourceLoader.load('res://Assets/GUI/DisabledBox.png')
onready var characters_node = get_node('/root/Game/CombatUI/M/V/H/Characters')
onready var combat_node = get_node('/root/Game/CombatUI')

signal monster_turn_completed



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
#	if active: # show the green selected_box
#		$BG.texture = selected_box
#		$BG/Info/M/V/Name.disabled = false
#	else: # don't show the green selected_box
#		$BG.texture = null
	if enabled:
		enable()
	else:
		disable()


func attack():
#	Process attack from active_monster.
	var message = ''
	var num_of_attacks = monster_data['attacks'].size()
#	Decide which character to attack. (STARTING WITHOUT ANY KIND OF AI, JUST RANDOMLY CHOOSING)
	randomize()
#	Determine if there are any living players:
	var player_hp = 0
	var character_index_to_attack
	var attacked_character_node
	for character in characters_node.get_children():
		player_hp += character.char_data['current_hp']
		if character.char_data['current_hp'] == 0:
			character.disable()
			character.update_ui(false)
#	for i in range( characters_node.get_child_count() ):
#		player_hp += characters_node.get_child(i).char_data['current_hp']
#		if characters_node.get_child(i).char_data['current_hp'] == 0:
#			characters_node.get_child(i).disable()
#			characters_node.get_child(i).update_ui(false)
	if player_hp > 0:
		while true: # Make sure the monster is attacking a living character.
			character_index_to_attack = randi() % characters_node.get_child_count()
			attacked_character_node = characters_node.get_child(character_index_to_attack)
			if attacked_character_node.char_data['current_hp'] > 0: # found a living character.
				break
		message += 'The ' + monster_data['name'] + ' attacked ' + attacked_character_node.char_data['name'] + ' and did damage: ('
		for i in range( monster_data['attacks'].size() ):
			var critical_miss = false
			var critical_hit = false
			var attack_roll = Global.roll_dice('1d20')
			if attack_roll == 0:  # Critical Miss
				critical_miss = true
				attack_roll = -20
			elif attack_roll == 20:  # Critical Hit
				critical_hit = true
			attack_roll += monster_data['attack_bonus']
			if attack_roll >= attacked_character_node.char_data['ac'] or critical_hit: # A hit
				var damage = Global.roll_dice( monster_data['damage'][i] )

			#	Apply damage.
				attacked_character_node.char_data['current_hp'] -= damage
				if attacked_character_node.char_data['current_hp'] < 0:
					attacked_character_node.char_data['current_hp'] = 0
					attacked_character_node.disable()
				message += monster_data['attacks'][i] + ': ' + str(damage) + "  "

			#	Hit Animation
				var hit_position = attacked_character_node.get_node('M/BG/Image/M/Image').get_global_position()
				combat_node.get_node('Animations/Position').set_global_position( hit_position )
				combat_node.get_node('Animations/Position/Slash').visible = true
				combat_node.get_node('Animations').play("slash")
				yield(combat_node.get_node('Animations'), "animation_finished")
				combat_node.get_node('Animations/Position/Slash').visible = false

				#emit_signal('monster_turn_completed')
				#attacked_character_node.update_ui(false)

			else:  # A miss.
				#print('IN ELSE: Monster missed')
				message += monster_data['attacks'][i] + ': Miss  '
				
				#	Miss Animation
				var anim_position = attacked_character_node.get_node('M/BG/Image/M/Image').get_global_position()
				combat_node.get_node('Animations/Position').set_global_position( anim_position )
				combat_node.get_node('Animations/Position/Miss').visible = true
				combat_node.get_node('Animations').play("miss")
				yield(combat_node.get_node('Animations'), "animation_finished")
				combat_node.get_node('Animations/Position/Miss').visible = false
				
				#print(' IN ELSE: added to message')
				#emit_signal('monster_turn_completed')
				#print(' IN ELSE: emitted signal monster_turn_completed')
				#attacked_character_node.update_ui(false)
		message += ')\n'
		#print( ' AFTER ELSE: added to message. ')
		#combat_node.get_node('M/V/H2/BG/M/Commentary').text += message
		#print( ' AFTER ELSE: displayed the message.' )
		attacked_character_node.update_ui(false)
		#print( ' AFTER ELSE: updated the ui on the attacked character.' )
		#emit_signal('monster_turn_completed')
		#print( ' AFTER ELSE: emitted the monster_turn_completed signal.' )
	else:
		combat_node.player_win = false
		emit_signal('end_combat')
	
	combat_node.get_node('M/V/H2/BG/M/Commentary').text += message
	#print( message )
	#return message


func _on_Name_pressed():
	# When the name is pressed, the Monster is selected and all other monsters are unselected.
	var monsters = self.get_parent().get_children()
	for monster in monsters:
		monster.selected = false
		monster.update_ui(false)
	get_node('/root/Game/CombatUI').selected_monster = my_index
	selected = true
	update_ui(false)