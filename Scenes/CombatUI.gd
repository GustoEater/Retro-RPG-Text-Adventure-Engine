extends NinePatchRect

var active_character
var active_monster
var selected_character
var selected_monster
var xp_earned = 0
var on_win
var on_lose
var player_win = false
export (int) var max_monsters = 6

onready var commentary = get_node('M/V/H2/BG/M/Commentary')
onready var monsters_node = get_node('M/V/H/Monsters')
onready var characters_node = get_node('M/V/H/Characters')
onready var story_ui_characters_node = get_node('/root/Game/StoryUI/M/FullWidth/Characters')
onready var melee_button = get_node('M/V/H/Commands/V/H4/MeleeButton')
onready var range_button = get_node('M/V/H/Commands/V/H4/RangeButton')
onready var wand_button = get_node('M/V/H/Commands/V/H4/WandButton')
onready var heal_button = get_node('M/V/H/Commands/V/H6/HealButton')

signal turn_completed
signal monster_turn_completed
signal end_combat


func prep_combat(monster_list, on_win_page, on_lose_page):
# Add Characters
	var target_parent_node = $M/V/H/Characters
	for i in range( Global.current_characters.size() ):
		var scene = load('res://Scenes/CharacterUI.tscn')
		var scene_instance = scene.instance()
		scene_instance.set_name( 'Character' + str(i) )
		target_parent_node.add_child(scene_instance)
		var new_node = target_parent_node.get_child(i)
	#	Fill in the data on the new node with info from character.
		new_node.my_index = i
		new_node.in_combat = true
		new_node.char_data = Global.current_characters[i]
		new_node.update_ui(true)
#	Parse the list of monsters and add to Global.current_monster_list array.
	Global.current_monster_list.clear()
	Global.current_monster_list = find_monsters( monster_list, '_' )
#	Calculate HP from the monster's Hit Dice
	for i in range( Global.current_monster_list.size() ):
		var hd = Global.all_monsters[ Global.current_monster_list[i] ]['hit_dice']
		randomize()
		var hp = Global.roll_dice( hd )
		Global.all_monsters[ Global.current_monster_list[i] ]['max_hp'] = hp
		if Global.all_monsters[ Global.current_monster_list[i] ].has('current_hp'):
			Global.all_monsters[ Global.current_monster_list[i] ]["current_hp"] = hp
#	Add MonsterUI information.
	target_parent_node = $M/V/H/Monsters
	for i in range( Global.current_monster_list.size() ):
		var scene = load('res://Scenes/MonsterUI.tscn')
		var scene_instance = scene.instance()
		scene_instance.set_name( 'Monster' + str(i) )
		target_parent_node.add_child(scene_instance)
		var new_node = target_parent_node.get_child(i)
	#	Fill in the data on the new node with info from monster.
		new_node.monster_data = Global.all_monsters[ Global.current_monster_list[i] ]
		new_node.my_index = i
		xp_earned += int(new_node.monster_data.xp)
	#	Select First Monster (and unselect the rest)
		if i == 0:
			selected_monster = 0
			new_node.selected = true
	#	Update the user interface (true = a full update)
		new_node.update_ui(true)

	on_win = on_win_page
	on_lose = on_lose_page
	set_process(true)


func find_monsters( list_text, between ):
# This function takes a string list and extracts the text between the specified characters.
# Returns an array of all the monsters
	var return_array = []
	var remaining_text = list_text
	for i in range( max_monsters ):
		# Will loop through this enough times to find all of the monsters.
		if remaining_text.find( between, 0 ) > 0:  # The 'between' is in the string
			var first_between = remaining_text.find( between, 0 )
			var next_between = remaining_text.find( between, first_between + 1 )
			var found = remaining_text.left( next_between )
			found = found.right( first_between + 1)
			return_array.append( found )
			remaining_text = remaining_text.right( next_between + 1 )
	return return_array

#func roll_dice( string ):
##	This function takes an input string like "1d6" and rolls the appropriate dice.
#	var sum = 0
##	Parse the string.
#	var number = int( string.left( string.findn( 'd' ) ) )
#	var type = int( string.right( string.length() - ( str(number).length() + 1) ) )
#	for i in range( number ):
#		randomize()
#		sum += randi() % type + 1
#	return sum


func start():
#	Sets up the beginning of combat.
	var opening_message = 'You are fighting a '
	var num_of_monsters = monsters_node.get_child_count()
	for i in range( num_of_monsters ):  # Shows what monsters are attacking.
		if i < num_of_monsters - 2 :
			opening_message += monsters_node.get_child(i).monster_data['name'] + ', a '
		elif i < num_of_monsters - 1:
			opening_message += monsters_node.get_child(i).monster_data['name'] + ', and a '
		else:
			opening_message += monsters_node.get_child(i).monster_data['name'] + '.\n'
	commentary.text = opening_message
#	Movest into the battle.
	battle()


func _ready():
	set_process(false)


func _process(delta):
#	Check for party win or lose.
	var player_hp = 0
	var enemy_hp = 0
	for i in range( characters_node.get_child_count() ):
		player_hp += characters_node.get_child(i).char_data['current_hp']
		if characters_node.get_child(i).char_data['current_hp'] == 0:
			characters_node.get_child(i).disable()
	for i in range( monsters_node.get_child_count() ):
		enemy_hp = enemy_hp + monsters_node.get_child(i).monster_data['current_hp']
	if enemy_hp <= 0:   # Player has won.
		player_win = true
		emit_signal('end_combat')
	if player_hp <= 0:  # Player has lost.
		player_win = false
		emit_signal('end_combat')


func battle():
	var enemy_hp = 0
	var player_hp = 0
	var num_of_fighters = characters_node.get_child_count() + monsters_node.get_child_count()
#	Total up HP from each fighter
	for i in range( characters_node.get_child_count() ):
		player_hp += int( characters_node.get_child(i).char_data['current_hp'] )
	for i in range( monsters_node.get_child_count() ):
		enemy_hp += int( monsters_node.get_child(i).monster_data['current_hp'] )
#	Main Battle Loop
	while enemy_hp > 0 and player_hp > 0:	# Each loop through is one round of play.
		roll_initiative()
	#	Deactivate all characters until we determine which one will be active.
		for character in characters_node.get_children():
			character.active = false

		var now_serving = num_of_fighters 
		for i in range( num_of_fighters + 1 ):
		#	Loop through each fighter and allow them to conduct their turn. Starting at highest 'combat_order'.
			for j in range( characters_node.get_child_count() ):  # Characters
				if characters_node.get_child(j).char_data['combat_order'] == now_serving:
					active_character = characters_node.get_child(j)
					if active_character.char_data['current_hp'] > 0:
				#	Highlight the active character.
						active_character.activate()
						active_character.update_ui(false)
				#	Wait for Player Input, once finished, the signal 'turn_completed' is emitted.
						yield(self, 'turn_completed')
				#	Once completed, deactivate the current player.
						active_character.active = false
						active_character.update_ui(false)
						#melee_button.visible = false
						#range_button.visible = false
						#wand_button.visible = false

			for j in range( monsters_node.get_child_count() ):  # Monsters
				if monsters_node.get_child(j) != null:
					if monsters_node.get_child(j).monster_data['combat_order'] == now_serving:
						active_monster = monsters_node.get_child(j)
						active_monster.attack()

						#print( message )
						#commentary.text += message
						#yield(active_monster, 'monster_turn_completed')
				else:
					pass	# Apparently that monster has already been killed.

		#	Serving the next player.
			now_serving -= 1
		
	#	End of round. Sum up enemy_hp and player_hp
		player_hp = 0
		enemy_hp = 0
		for i in range( characters_node.get_child_count() ):
			player_hp += characters_node.get_child(i).char_data['current_hp']
			if characters_node.get_child(i).char_data['current_hp'] == 0:
				characters_node.get_child(i).disable()
		for i in range( monsters_node.get_child_count() ):
			enemy_hp = enemy_hp + monsters_node.get_child(i).monster_data['current_hp']
		commentary.text += '\n========== End of Round ==========\n'
		if enemy_hp <= 0:   # Player has won.
			player_win = true
			emit_signal('end_combat')
		if player_hp <= 0:  # Player has lost.
			player_win = false
			emit_signal('end_combat')


func roll_initiative():
	var available_ranks = []
	var max_size
	var decreasing = true
	available_ranks.resize( $M/V/H/Monsters.get_child_count() + characters_node.get_child_count() )
	for i in range( available_ranks.size() ):
		available_ranks[i] = int(i)
		max_size = i
#	Loop through the characters first and assign ranks.
	for i in range( characters_node.get_child_count() - 1 ):
		randomize()
		var num_to_try  = randi() % available_ranks.size() # + 1
		num_to_try += characters_node.get_child(i).char_data['dex_bonus']
		if num_to_try > max_size:
			num_to_try = max_size
		num_to_try = int(num_to_try)
		if !available_ranks.has( num_to_try ):
		#	The number to try doesn't appear in the available numbers.
		#	We need to subtract one from it and check again. We can do this up to 6 times.
			for x in range( max_size * 2 ):
				if decreasing:
					num_to_try -= 1
				else:
					num_to_try += 1
				if num_to_try < 0:
					decreasing = false
					num_to_try += 1
				if !available_ranks.has( num_to_try ):
					# the number is still not available then subtract.
					pass
				else:
					break
		available_ranks.remove( available_ranks.find( num_to_try ) )
		characters_node.get_child(i).char_data['combat_order'] = num_to_try
#	Loop through the monsters and assign ranks.
	for i in range( monsters_node.get_child_count() ):
		randomize()
		var num_to_try  = randi() % available_ranks.size() # + 1
		num_to_try = int(num_to_try)
		if !available_ranks.has( num_to_try ):
			# the number to try doesn't appear in the available numbers.
			# here we need to subtract one from it and check again. We can do this up to 6 times.
			decreasing = true
			for x in range( max_size * 2 ):
				if decreasing:
					num_to_try -= 1
				else:
					num_to_try += 1
				if num_to_try < 0:
					decreasing = false
					num_to_try += 1
				if !available_ranks.has( num_to_try ):
					# the number is still not available then subtract.
					pass
				else:
					break
		available_ranks.remove( available_ranks.find( num_to_try ) )
		monsters_node.get_child(i).monster_data['combat_order'] = num_to_try


func character_attack(attack_type, weapon):
	var selected_monster_node = get_node('M/V/H/Monsters/Monster' + str(selected_monster) )
	var monster_ac = selected_monster_node.monster_data['ac']
	var critical_hit = false
	var critical_miss = false
	var attack_roll = Global.roll_dice('1d20')
	if attack_roll == 20:
		critical_hit = true
		commentary.text += 'CRITICAL HIT! Double damage!\n'
	if attack_roll == 1:  # A critical miss always misses.
		critical_miss = true
		commentary.text += 'CRITIICAL MISS!\n'
		attack_roll = -10  # This is so that even if the really low roll hits, it will miss
	attack_roll += active_character.char_data['attack_bonus']
	if attack_type == 'melee':
		attack_roll += active_character.char_data['str_bonus']
	elif attack_type == 'range':
		attack_roll += active_character.char_data['dex_bonus']
	elif attack_type == 'wand':
		attack_roll += active_character.char_data['int_bonus']
	if attack_roll >= monster_ac or critical_hit:   # A Hit

		var damage = Global.roll_dice( active_character.char_data['weapons'][ attack_type + '_damage' ] )
		if critical_hit:
			damage = damage * 2
		selected_monster_node.monster_data['current_hp'] -= damage
		commentary.text += active_character.char_data['name'] + ' hit ' + selected_monster_node.monster_data['name'] + ' with a ' + weapon + ' (rolled ' + str(attack_roll) + ') and did ' + str(damage) + ' damage.\n'

	#	Hit Animation
		var hit_position = selected_monster_node.get_node('BG/Image/M/Image').get_global_position()
		$Animations/Position.set_global_position( hit_position )
		$Animations/Position/Slash.visible = true
		$Animations.play("slash")
		yield($Animations, "animation_finished")
		$Animations/Position/Slash.visible = false

		if selected_monster_node.monster_data['current_hp'] <= 0:  # Monster has been killed.
			#xp_earned += int(selected_monster_node.monster_data['xp'])
			#print('Just earned ', xp_earned )
			selected_monster_node.monster_data['current_hp'] = 0
			if monsters_node.get_child_count() == 1:  # The last monster was killed. Battle is won.
				commentary.text += 'You won!\n'
				emit_signal('end_combat')
			else:   # There are still monsters remaining.
				selected_monster_node.selected = false
				monsters_node.remove_child(selected_monster_node)
				var remaining_monsters = monsters_node.get_children()
				#print( remaining_monsters )
				remaining_monsters[0].selected = true
				selected_monster = remaining_monsters[0].name.right( remaining_monsters[0].name.length() - 1 )
				remaining_monsters[0].update_ui(false)
		else:
			selected_monster_node.update_ui(false)
	else:
		commentary.text += active_character.char_data['name'] + ' missed ' + selected_monster_node.monster_data['name'] + ' with a ' + weapon + ' (rolled ' + str(attack_roll) + ').\n'
		
		#	Miss Animation
		var anim_position = selected_monster_node.get_node('BG/Image/M/Image').get_global_position()
		$Animations/Position.set_global_position( anim_position )
		$Animations/Position/Miss.show()
		$Animations.play("miss")
		yield($Animations, "animation_finished")
		$Animations/Position/Miss.hide()

	return true


func _on_CombatUI_end_combat():
	set_process(false)
	if $Animations.is_playing():
		yield($Animations, 'animation_finished')
		# Halt everything!!
		#$Animations.stop()
		for child in $Animations/Position.get_children():
			child.hide()
		#$Animations/Position/Slash.hide()
		#NOTE, NEED TO MAKE THIS A LOOP.
	
	if player_win:
		for i in range( characters_node.get_child_count() ):
			Global.current_characters[i]['xp'] += xp_earned
		$EndCombatWin/MarginContainer/VBoxContainer/Label3.text = str(xp_earned) + " XP"
		$EndCombatWin.show()
	else:
		xp_earned = 0
		$EndCombatLose.show()


func _on_DoneButton_pressed():
#	Send back to the StoryUI and Clean Up
	for monster in monsters_node.get_children():
		monster.queue_free()
	for character in characters_node.get_children():
		character.queue_free()
	xp_earned = 0
	
	if player_win:
		$EndCombatWin.hide()
		self.get_parent().get_node('/root/Game/StoryUI').update_page( int(on_win) )
		self.get_parent().get_node('/root/Game/StoryUI').show()
	else:
		$EndCombatLose.hide()
		self.get_parent().get_node('/root/Game/StoryUI').update_page( int(on_lose) )
		self.get_parent().get_node('/root/Game/StoryUI').show()
#	Copy updated stats from the combat back into the Global variables.
	var return_char_stats = []
	for character in characters_node.get_children():
		return_char_stats.append( character.char_data )
	Global.current_characters.clear()
	Global.current_characters = return_char_stats
#	Update UI on StoryUI Characters.
	for character in story_ui_characters_node.get_children():
		character.update_ui(true)
#	Close combat results.
	self.hide()


func _on_MeleeButton_pressed():
	melee_button.hide()
	range_button.hide()
	wand_button.hide()
	heal_button.hide()
	
	var useless = character_attack('melee', active_character.char_data['weapons']['melee'])
	emit_signal('turn_completed')


func _on_RangeButton_pressed():
	melee_button.hide()
	range_button.hide()
	wand_button.hide()
	heal_button.hide()
	
	character_attack('range', active_character.char_data['weapons']['range'])
	emit_signal('turn_completed')


func _on_WandButton_pressed():
	melee_button.hide()
	range_button.hide()
	wand_button.hide()
	heal_button.hide()
	
	character_attack('wand', active_character.char_data['weapons']['wand'])
	emit_signal('turn_completed')


func _on_HealButton_pressed():
	var selected_count = 0
	var message = active_character.char_data['name'] + ' healed '
	for character in characters_node.get_children():
		if character.selected:
			message += character.char_data['name'] + '  '
			selected_count += 1
	if selected_count > 0:
		# Heal all of the selected characters ( divide the total heal amount by the number of players and round)
		var heal_amount = 0
		heal_amount = Global.roll_dice( active_character.char_data['spells']['heal_amount'] )
		#print( 'Healing: ', heal_amount )
		heal_amount = int( heal_amount / selected_count )  # divide into each.
		message += ' for ' + str(heal_amount) + '.'
		#print( 'Healing: ', heal_amount )
		for character in characters_node.get_children():
			if character.selected:
				character.char_data['current_hp'] += heal_amount
				character.update_ui(false)
				# ALSO NEED TO PLAY THE ANIMATIONS

		commentary.text += message
		emit_signal('turn_completed')
	
	
		
	else:
		# Send up a dialog box telling the player to select a character to heal first.
		$NoSelectionDialog.show()


