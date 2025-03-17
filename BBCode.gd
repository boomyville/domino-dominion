extends Node


#================================================================
# BB code functions
#================================================================

func bb_code_dot(num: int):
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/" + str(num) + "Tile.png[/img][/font]"

func bb_code_wild_dot(num: int):
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Wild" + str(num) + "Tile.png[/img][/font]"


func bb_code_tile(get_numbers: Array):
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/" + str(get_numbers[0]) + "Tile.png[/img][/font] [font=res://Fonts/VAlign.tres][img]res://Icons/" + str(get_numbers[1]) + "Tile.png[/img][/font]"

func bb_code_max_tile(get_numbers: Array):
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/" + str(max(get_numbers[0], get_numbers[1])) + "Tile.png[/img][/font]"

func bb_code_min_tile(get_numbers: Array):
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/" + str(min(get_numbers[0], get_numbers[1])) + "Tile.png[/img][/font]"

func bb_code_superup():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/SuperUp.png[/img][/font]"

func bb_code_up():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Up.png[/img][/font]"

func bb_code_attack():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Attack.png[/img][/font]"

func bb_code_arrow():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Arrow.png[/img][/font]"

func bb_code_double():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Double.png[/img][/font]"

func bb_code_quadruple():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Quadruple.png[/img][/font]"

func bb_code_triple():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Triple.png[/img][/font]"

func bb_code_shield():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Shield.png[/img][/font]"

func bb_code_copy():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Copy.png[/img][/font]"

func bb_code_discard():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Discard.png[/img][/font]"

func bb_code_draw():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Draw.png[/img][/font]"

func bb_code_max_shield():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/MaxShield.png[/img][/font]"

func bb_code_void():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Void.png[/img][/font]"
func bb_code_pile():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Pile.png[/img][/font]"
func bb_code_shuffle():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/SHuffle.png[/img][/font]"
	
func bb_code_search():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Search.png[/img][/font]"
	
func bb_code_vulnerable():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Vulnerable.png[/img][/font]"
			
func bb_code_fury():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Fury.png[/img][/font]"
		
func bb_code_frostbite():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Frostbite.png[/img][/font]"
		
func bb_code_paralysis():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Paralysis.png[/img][/font]"
		
func bb_code_petrify():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Petrified.png[/img][/font]"
		
func bb_code_burn():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Burn.png[/img][/font]"
		
func bb_code_spikes():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Spikes.png[/img][/font]"

func bb_code_blessing():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/AutoRevive.png[/img][/font]"

func bb_code_action_point():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/ActionPoint.png[/img][/font]"

func bb_code_bulwark():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Bulwark.png[/img][/font]"

func bb_code_nullify():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Nullify.png[/img][/font]"
		
func bb_code_half():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Half.png[/img][/font]"
func bb_code_frenzy():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Frenzy.png[/img][/font]"
	
func bb_code_impair():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Impair.png[/img][/font]"

func bb_code_precision():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Precision.png[/img][/font]"
			
func bb_code_ephemeral():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Ephemeral.png[/img][/font]"
			
func bb_code_anxious():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Anxious.png[/img][/font]"

func bb_code_fortitude():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Fortitude.png[/img][/font]"
				
func bb_code_berserk():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Berserk.png[/img][/font]"

func bb_code_multiply():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Multiply.png[/img][/font]"
		
func bb_code_plus():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Plus.png[/img][/font]"
		
func bb_code_heal():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Heal.png[/img][/font]"
		
func bb_code_gem():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Gem.png[/img][/font]"

func bb_code_random():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Random.png[/img][/font]"
