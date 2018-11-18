extends NinePatchRect

var active_character
var active_monster
var selected_character
var selected_monster
var xp_earned = 0
var on_win
var on_lose
var player_win = false

onready var commentary = get_node('M/V/H2/BG/M/Commentary')
onready var monsters_node = get_node('M/V/H/Monsters')
onready var characters_node = get_node('M/V/H/Characters')
onready var story_ui_characters_node = get_node('/root/Game/StoryUI/M/FullWidth/Characters')

#onready var selected_box = ResourceLoader.load('res://Assets/GUI/SelectedBox.png')
#onready var disabled_box = ResourceLoader.load('res://Assets/GUI/CommentaryShade.png')

signal turn_completed
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
		new_node.combat = true
		new_node.char_data = Global.current_characters[i]
		new_node.update_ui(true)
#	Parse the list of monsters and add to Global.current_monster_list array.
	Global.current_monster_list.clear()
	var number_of_monsters = monster_list.left( monster_list.findn( ':' ) )
	monster_list = monster_list.right( monster_list.findn( ':' ) + 1 )
	monster_list = monster_list.right ( 3 )   # remove leading \n\r\n from the beginning.
	for i in range( number_of_monsters ):
		Global.current_monster_list.append( monster_list.left( monster_list.findn( '\n' ) ) )
		monster_list = monster_list.right( Global.current_monster_list[ i ].length() + 3 )
		Global.current_monster_list[ i ] = Global.current_monster_list[ i ].right( 1 )
		Global.current_monster_list[ i ] = Global.current_monster_list[ i ].left( Global.current_monster_list[ i ].length() - 1 )
#	Calculate HP from the monster's Hit Dice
	for i in range( Global.current_monster_list.size() ):
		var hd = Global.all_monsters[ Global.current_monster_list[i] ]['hit_dice']
		var hp = roll_dice( hd )
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
	#	The first monster should be selected (all others should not be selected)
		if i == 0:
			selected_monster = 0
			new_node.selected = true
	#	Update the user interface (true = a full update)
		new_node.update_ui(true)
	on_win = on_win_page
	on_lose = on_lose_page


func roll_dice( string ):
#	This function takes an input string like "1d6" and rolls the appropriate dice.
#	Parse the string.
	var sum = 0
	var number = int( string.left( string.findn( 'd' ) ) )
	var type = int( string.right( string.length() - ( str(number).length() + 1) ) )
	for i in range( number ):
		randomize()
		sum += randi() % type + 1
	return sum


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
	battle()


func battle():
#	Main Battle Loop
	var enemy_hp = 0
	var player_hp = 0
	var num_of_fighters = characters_node.get_child_count() + monsters_node.get_child_count()
#	Total up HP from each fighter
	for i in range( characters_node.get_child_count() ):
		player_hp += characters_node.get_child(i).char_data['current_hp']
	for i in range( monsters_node.get_child_count() ):
		enemy_hp = enemy_hp + int( monsters_node.get_child(i).monster_data['current_hp'] )

	while enemy_hp > 0 and player_hp > 0:
		roll_initiative()
	#	Conduct this loop until one of the sides has lost. This is one round of fighting.
	#	Deactivate all characters until we determine which one will be active.
		for character in characters_node.get_children():
			character.active = false

		var now_serving = num_of_fighters 
		for i in range( num_of_fighters + 1 ):
		#	Loop through each fighter and allow them to conduct their turn. Starting at highest 'combat_order'.
			for j in range( characters_node.get_child_count() ):  # Characters
				if characters_node.get_child(j).char_data['combat_order'] == now_serving:
				#	Found the character whose turn it is.
					active_character = characters_node.get_child(j)
					if active_character.char_data['current_hp'] > 0:
						commentary.text = commentary.text + "\nIt's " + active_character.char_data['name'] + "'s Turn"
						$M/V/H/Commands/V/MeleeButton.disabled = false
						$M/V/H/Commands/V/RangeButton.disabled = false
						$M/V/H/Commands/V/WandButton.disabled = false
				#	Highlight the active character.
						active_character.activate()
						active_character.update_ui(false)
				#	Wait for Player Input, once finished, the signal 'turn_completed' is emitted.
						yield(self, 'turn_completed')
				#	Deselect the active character.
						active_character.active = false
						active_character.update_ui(false)

			for j in range( monsters_node.get_child_count() ):  # Monsters
				if monsters_node.get_child(j).monster_data['combat_order'] == now_serving:
					commentary.text = commentary.text + "\nIt's " + monsters_node.get_child(j).monster_data['name'] + "'s Turn"
					active_monster = monsters_node.get_child(j)
					monster_attack()
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
#		The below code may never run since I'm now using a signal to end the battle.
		if enemy_hp <= 0:   # Player has won.
		# close everything and go to the on_win page
			player_win = true
			emit_signal('end_combat')
		if player_hp <= 0:  # Player has lost.
		# close everything and go to the on_lose page
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


func monster_attack():
#	Process attack from active_monster.
	var num_of_attacks = active_monster.monster_data['attacks'].size()
#	Decide which character to attack. (STARTING WITHOUT ANY KIND OF AI, JUST RANDOMLY CHOOSING)
	randomize()
#	Determine if there are any living players:
	var player_hp = 0
	var character_to_attack
	var attacked_character_node
	for i in range( characters_node.get_child_count() ):
		player_hp += characters_node.get_child(i).char_data['current_hp']
		if characters_node.get_child(i).char_data['current_hp'] == 0:
			characters_node.get_child(i).disable()
			characters_node.get_child(i).update_ui(false)
	if player_hp > 0:
		while true: # Make sure the monster is attacking a living character.
			character_to_attack = randi() % characters_node.get_child_count()
			attacked_character_node = characters_node.get_child(character_to_attack)
			if attacked_character_node.char_data['current_hp'] > 0:
				break
		var message = ' The ' + active_monster.monster_data['name'] + ' attacks ' + attacked_character_node.char_data['name'] + '.'
		commentary.text += message
		for i in range( active_monster.monster_data['attacks'].size() ):
			var critical_miss = false
			var critical_hit = false
			randomize()
			var attack_roll = roll_dice('1d20')
			if attack_roll == 0:  # Critical Miss
				critical_miss = true
				attack_roll = -20
			elif attack_roll == 20:  # Critical Hit
				critical_hit = true
			attack_roll += active_monster.monster_data['attack_bonus']
			if attack_roll >= attacked_character_node.char_data['ac'] or critical_hit: # A hit
				var damage = roll_dice( active_monster.monster_data['damage'][i] )
			#	Apply damage.
				attacked_character_node.char_data['current_hp'] -= damage
				if attacked_character_node.char_data['current_hp'] < 0:
					attacked_character_node.char_data['current_hp'] = 0
					attacked_character_node.disable()
				message = ' The ' + active_monster.monster_data['name'] + ' attacks with ' + active_monster.monster_data['attacks'][i] + ' and does ' + str(damage) + ' damage.'
				commentary.text += message
				attacked_character_node.update_ui(false)
			else:  # A miss.
				message = ' The ' + active_monster.monster_data['name'] + ' attacks with ' + active_monster.monster_data['attacks'][i] + ' but misses.'
				commentary.text += message
	else:
		# It seems that all the characters are dead. Are they?
		pass


func character_attack(attack_type):
	var selected_monster_node = get_node('M/V/H/Monsters/Monster' + str(selected_monster) )
	var monster_ac = selected_monster_node.monster_data['ac']
	var message = '\n'
	var critical_hit = false
	var critical_miss = false
	var attack_roll = roll_dice('1d20')
	if attack_roll == 20:
		critical_hit = true
		message += 'CRITICAL HIT! Double damage!\n'
	if attack_roll == 1:  # A critical miss always misses.
		critical_miss = true
		message += 'CRITIICAL MISS!\n'
		attack_roll = -10  # This is so that even if the really low roll hits, it will miss
	attack_roll += active_character.char_data['attack_bonus'] + active_character.char_data['str_bonus']
	if attack_roll >= monster_ac or critical_hit:   # A Hit
		message = '\n' + active_character.char_data['name'] + ' hit ' + selected_monster_node.monster_data['name'] + ' with a roll of ' + str(attack_roll) + '.'
		var damage = roll_dice( active_character.char_data['weapons'][ attack_type + '-damage' ] )
		if critical_hit:
			damage = damage * 2
		message += '\n' + selected_monster_node.monster_data['name'] + ' took ' + str(damage) + ' sword damage.'
		selected_monster_node.monster_data['current_hp'] -= damage

	#	Hit Animation
		$slash/Sprite.translate( Vector2(200, 200) )  # While this moves the sprite...it does so relatively.
		$slash/Sprite.visible = true
		$slash.play("slash")
		yield($slash, "animation_finished")
		$slash/Sprite.visible = false

		if selected_monster_node.monster_data['current_hp'] <= 0:  # Monster has been killed.
			xp_earned += int(selected_monster_node.monster_data['xp'])
			selected_monster_node.monster_data['current_hp'] = 0
			if monsters_node.get_child_count() == 1:  # The last monster was killed. Battle is won.
				message = 'You won!'
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
		message = active_character.char_data['name'] + ' missed ' + selected_monster_node.monster_data['name'] + ' with a roll of ' + str(attack_roll) + '.'
	commentary.text += message


func _on_MeleeButton_pressed():
	$M/V/H/Commands/V/MeleeButton.disabled = true
	$M/V/H/Commands/V/RangeButton.disabled = true
	$M/V/H/Commands/V/WandButton.disabled = true
	
	character_attack('melee')
	emit_signal('turn_completed')


func _on_CombatUI_end_combat():
	if player_win:
		#print('XP Earned: ', str(xp_earned) )
		for i in range( characters_node.get_child_count() ):
			Global.current_characters[i]['xp'] += xp_earned
		
		$EndCombatWin/MarginContainer/VBoxContainer/Label3.text = str(xp_earned) + " XP"
		$EndCombatWin.show()
	else:
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
		self.get_parent().get_node('/root/Game/StoryUI').update_page(on_win)
		self.get_parent().get_node('/root/Game/StoryUI').show()
	else:
		$EndCombatLose.hide()
		self.get_parent().get_node('/root/Game/StoryUI').update_page(on_lose)
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


func _on_RangeButton_pressed():
	$M/V/H/Commands/V/MeleeButton.disabled = true
	$M/V/H/Commands/V/RangeButton.disabled = true
	$M/V/H/Commands/V/WandButton.disabled = true
	
	character_attack('range')
	emit_signal('turn_completed')


func _on_WandButton_pressed():
	$M/V/H/Commands/V/MeleeButton.disabled = true
	$M/V/H/Commands/V/RangeButton.disabled = true
	$M/V/H/Commands/V/WandButton.disabled = true
	
	character_attack('wand')
	emit_signal('turn_completed')
