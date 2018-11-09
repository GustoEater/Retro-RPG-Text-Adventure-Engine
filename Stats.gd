extends Node

# The "Stats" of the character.

export (String) var char_name
export (String) var gender
export (String) var race
export (String) var char_class
export (int) var strength
export (int) var intel
export (int) var wis
export (int) var dex
export (int) var con
export (int) var cha
export (int) var level
export (int) var xp
export (int) var ac
export (int) var max_hp
export (int) var current_hp
export (int) var max_mp
export (int) var current_mp
export (int) var combat_order
export (int) var attack_bonus
export (int) var str_bonus
export (int) var int_bonus
export (int) var wis_bonus
export (int) var dex_bonus
export (int) var con_bonus
export (int) var cha_bonus
export (int) var save_death
export (int) var save_wands
export (int) var save_stone
export (int) var save_dragon
export (int) var save_spells
export (String, FILE, "*.png") var picture
export (Array) var weapons = []
export (Array) var spells = []
export (Array) var armor = []


func import_from_dict(from_dict):
	# This function will take a dictionary (which is a single character "sheet" pulled from the "Characters.JSON" file.
	char_name = from_dict.name
	gender = from_dict.gender
	race = from_dict.race
	char_class = from_dict.class
	strength = from_dict.str
	intel = from_dict.int
	wis = from_dict.wis
	dex = from_dict.dex
	con = from_dict.con
	cha = from_dict.chr
	level = from_dict.level
	xp = from_dict.xp
	ac = from_dict.ac
	max_hp = from_dict.max_hp
	current_hp = from_dict.current_hp
	max_mp = from_dict.max_mp
	current_mp = from_dict.current_mp
	combat_order = from_dict.combat_order
	attack_bonus = from_dict.attack_bonus
	str_bonus = from_dict.str_bonus
	int_bonus = from_dict.int_bonus
	wis_bonus = from_dict.wis_bonus
	dex_bonus = from_dict.dex_bonus
	con_bonus = from_dict.con_bonus
	cha_bonus = from_dict.chr_bonus
	save_death = from_dict.save_death
	save_wands = from_dict.save_wands
	save_stone = from_dict.save_stone
	save_dragon = from_dict.save_dragon
	save_spells = from_dict.save_spells
	picture = from_dict.pic
	#weapons = from_dict.weapons
	#spells = from_dict.spells
	#armor = from_dict.armor


func output_to_dict():
	# This function will return a dictionary containing all of the "Stats". I think the dictionary then goes into a function.
	pass


