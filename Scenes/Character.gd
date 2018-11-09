extends MarginContainer

var current_characters = []
signal turn_completed





func update_characters(characters_array):
	# This can be called from other modules I believe. This takes in an array of 4 members, with dictionaries in them, one
	# for each character. Then it updates the character information in each of the blocks to match the array.
	current_characters = characters_array
	
	$LeftBlock/Character1/Info/m/v/m/Name1.text = characters_array[0].name
	$LeftBlock/Character2/Info/m/v/m/Name2.text = characters_array[1].name
	$LeftBlock/Character3/Info/m/v/m/Name3.text = characters_array[2].name
	$LeftBlock/Character4/Info/m/v/m/Name4.text = characters_array[3].name
	
	$LeftBlock/Character1/Info/m/v/HealthBar.max_value = characters_array[0].max_hp
	$LeftBlock/Character2/Info/m/v/HealthBar.max_value = characters_array[1].max_hp
	$LeftBlock/Character3/Info/m/v/HealthBar.max_value = characters_array[2].max_hp
	$LeftBlock/Character4/Info/m/v/HealthBar.max_value = characters_array[3].max_hp
	
	$LeftBlock/Character1/Info/m/v/HealthBar.value = characters_array[0].current_hp
	$LeftBlock/Character2/Info/m/v/HealthBar.value = characters_array[1].current_hp
	$LeftBlock/Character3/Info/m/v/HealthBar.value = characters_array[2].current_hp
	$LeftBlock/Character4/Info/m/v/HealthBar.value = characters_array[3].current_hp
	
	
	$LeftBlock/Character1/Info/m/v/MagicBar.max_value = characters_array[0].max_mp
	$LeftBlock/Character2/Info/m/v/MagicBar.max_value = characters_array[1].max_mp
	$LeftBlock/Character3/Info/m/v/MagicBar.max_value = characters_array[2].max_mp
	$LeftBlock/Character4/Info/m/v/MagicBar.max_value = characters_array[3].max_mp
	
	$LeftBlock/Character1/Info/m/v/MagicBar.value = characters_array[0].current_mp
	$LeftBlock/Character2/Info/m/v/MagicBar.value = characters_array[1].current_mp
	$LeftBlock/Character3/Info/m/v/MagicBar.value = characters_array[2].current_mp
	$LeftBlock/Character4/Info/m/v/MagicBar.value = characters_array[3].current_mp
	
	var image = []
	var texture = []
	
	for j in range(4):
		image.append(Image.new())
		image[j].load("res://Assets/Character/" + current_characters[j].pic)
		texture.append(ImageTexture.new())
		texture[j].create_from_image(image[j])
	
	$LeftBlock/Character1/Image/m/Picture.texture = texture[0]
	$LeftBlock/Character2/Image/m/Picture.texture = texture[1]
	$LeftBlock/Character3/Image/m/Picture.texture = texture[2]
	$LeftBlock/Character4/Image/m/Picture.texture = texture[3]
	
	
	

func prep_popup(i):
	# First update the data fields that are going to show up on the page.
	# Since this is the first character that's been clicked, we use item 0 in the array.
	$PopupPanel/m/h/v/h2/v/Name.text = current_characters[i].name
	$PopupPanel/m/h/v/h2/v/Gender.text = current_characters[i].gender
	$PopupPanel/m/h/v/h2/v/Race.text = current_characters[i].race
	$PopupPanel/m/h/v/h2/v/Class.text = current_characters[i].class
	
	$PopupPanel/m/h/v/h2/h/v/v2/HP.text = str(current_characters[i].current_hp) + " / " + str(current_characters[i].max_hp)
	$PopupPanel/m/h/v/h2/h/v/v2/MP.text = str(current_characters[i].current_mp) + " / " + str(current_characters[i].max_mp)
	$PopupPanel/m/h/v/h2/h/v/v2/AC.text = str(current_characters[i].ac)
	$PopupPanel/m/h/v/h2/h/v/v2/AB.text = str(current_characters[i].attack_bonus)
		
	$PopupPanel/m/h/h/v2/Str.text = str(current_characters[i].str)
	$PopupPanel/m/h/h/v2/Int.text = str(current_characters[i].int)
	$PopupPanel/m/h/h/v2/Wis.text = str(current_characters[i].wis)
	$PopupPanel/m/h/h/v2/Dex.text = str(current_characters[i].dex)
	$PopupPanel/m/h/h/v2/Con.text = str(current_characters[i].con)
	$PopupPanel/m/h/h/v2/Chr.text = str(current_characters[i].chr)
	
	$PopupPanel/m/h/h/v5/Death.text = str(current_characters[i].save_death)
	$PopupPanel/m/h/h/v5/Wands.text = str(current_characters[i].save_wands)
	$PopupPanel/m/h/h/v5/Stone.text = str(current_characters[i].save_stone)
	$PopupPanel/m/h/h/v5/Dragon.text = str(current_characters[i].save_dragon)
	$PopupPanel/m/h/h/v5/Spells.text = str(current_characters[i].save_spells)
	
	if current_characters[i].str_bonus != 0:
		$PopupPanel/m/h/h/v3/StrB.text = str(current_characters[i].str_bonus)
	else:
		$PopupPanel/m/h/h/v3/StrB.text = ""
		
	if current_characters[i].int_bonus != 0:
		$PopupPanel/m/h/h/v3/IntB.text = str(current_characters[i].int_bonus)
	else:
		$PopupPanel/m/h/h/v3/IntB.text = ""
		
	if current_characters[i].wis_bonus != 0:
		$PopupPanel/m/h/h/v3/WisB.text = str(current_characters[i].wis_bonus)
	else:
		$PopupPanel/m/h/h/v3/WisB.text = ""
		
	if current_characters[i].dex_bonus != 0:
		$PopupPanel/m/h/h/v3/DexB.text = str(current_characters[i].dex_bonus)
	else:
		$PopupPanel/m/h/h/v3/DexB.text = ""
		
	if current_characters[i].con_bonus != 0:
		$PopupPanel/m/h/h/v3/ConB.text = str(current_characters[i].con_bonus)
	else:
		$PopupPanel/m/h/h/v3/ConB.text = ""
		
	if current_characters[i].chr_bonus != 0:
		$PopupPanel/m/h/h/v3/ChrB.text = str(current_characters[i].chr_bonus)
	else:
		$PopupPanel/m/h/h/v3/ChrB.text = ""
	
	var image = Image.new()
	image.load("res://Assets/Character/" + current_characters[i].pic)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	$PopupPanel/m/h/v/h2/h/Image.texture = texture
	
	
	$PopupPanel.margin_left = 250
	$PopupPanel.margin_top = 20
	$PopupPanel.margin_bottom = get_viewport().size.y - 20
	$PopupPanel.margin_right = get_viewport().size.x - 20	



func _on_Name1_pressed():
	prep_popup(0)
	get_node("PopupPanel").popup()


func _on_Name2_pressed():
	prep_popup(1)
	get_node("PopupPanel").popup()


func _on_Name3_pressed():
	prep_popup(2)
	get_node("PopupPanel").popup()


func _on_Name4_pressed():
	prep_popup(3)
	get_node("PopupPanel").popup()


func _on_Done_pressed():
	get_node("PopupPanel").hide()


func Player_Turn(target_player):
		print( "It's ", target_player['name'], "'s turn." )
		emit_signal("turn_completed")
