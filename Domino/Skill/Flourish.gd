extends DominoContainer

# Growth Mindset
# Upgrade all dominos in hand
# Downgrade - Upgrade 1 domino in hand
# Upgrade+ - Upgrade all dominos in hand. Can over-upgrade
# Upgrade++ - Upgrade all dominos in hand. Can over-upgrade. Top stack

func _init():
	pip_data = { "left": [1, 3, "dynamic"], "right": [4, 6, "dynamic"] }
	domino_name = "Flourish"
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2, 3:
			criteria = ["uncommon", "any"]
		4:
			criteria = ["uncommon", "top_stack", "any"]
		_:
			print("Error: Invalid upgrade level")
			criteria = ["uncommon", "any"]
	
func get_description() -> String:
	match get_upgrade_level():
		0:
			return BBCode.bb_code_up() + " 1 domino in hand"
		1:
			return BBCode.bb_code_up() + " All dominos in hand"
		2, 3:
			return BBCode.bb_code_superup() + " All dominos in hand"	
		_:
			print("Error: Invalid upgrade level")	
			return BBCode.bb_code_up() + " 1 domino in hand"
		
func get_detailed_description():
	var msg = get_pip_description()
	match get_upgrade_level():
		0:
			msg += BBCode.bb_code_up() + " Upgrade 1 domino in hand"
		1:
			msg += BBCode.bb_code_up() + " Upgrade all dominos in hand"
		2, 3:
			msg += BBCode.bb_code_superup() + " Super upgrade all dominos in hand\n"
			msg += "Sets all dominos to maximum upgrade level"
	return msg

func effect(origin, target):
	
	match get_upgrade_level():
		0:
			Game.get_node("Game").domino_selection(1, get_upgrade_level(), self, self.user, "hand", -1, "same_hand", {"alter_upgrade_domino": [1]})
			yield(self, "pre_effect_complete")
		1:
			for domino in origin.get_hand().get_children():
				if not domino.check_shadow_match(self):
					domino.alter_upgrade_domino(1)
		2, 3:
			for domino in origin.get_hand().get_children():
				if not domino.check_shadow_match(self):
					domino.alter_upgrade_domino(2)
	
	.effect(origin, target)
	
	var animation = preload("res://Battlers/Animations/Flourish.tscn")
	spell(origin, origin, 0, "spell", animation)

