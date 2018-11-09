extends Node

# The "Stats" of the character.

var name
var gender
var race
var _class
var strength
var intel
var wis
var dex
var con
var cha
var level
var xp
var ac
var max_hp
var current_hp
var max_mp
var current_mp
var combat_order
var attack_bonus
var str_bonus
var int_bonus
var wis_bonus
var dex_bonus
var con_bonus
var cha_bonus
var save_death
var save_wands
var save_stone
var save_dragon
var save_spells
var picture
var weapons = []
var spells = []
var armor = []


func import_from_dict(from_dict):
	# This function will take a dictionary (which is a single character "sheet" pulled from the "Characters.JSON" file.
	name = from_dict.name
	gender = from_dict.gender
	race = from_dict.race
	_class = from_dict.class
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
	cha_bonus = from_dict.cha_bonus
	save_death = from_dict.save_death
	save_wands = from_dict.save_wands
	save_stone = from_dict.save_stone
	save_dragon = from_dict.save_dragon
	save_spells = from_dict.save_spells
	picture = from_dict.pic
	weapons = from_dict.weapons
	spells = from_dict.spells
	armor = from_dict.armor


func output_to_dict():
	# This function will return a dictionary containing all of the "Stats". I think the dictionary then goes into a function.
	pass


