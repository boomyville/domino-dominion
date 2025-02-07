extends DominoContainer

# Reroll
# Downgrade - Rerolled domino only 1 -3
# Upgrade+ - Reroll 2 dominos
# Upgrade++ - Reroll 3 dominos
# Upgrade+++ - Reroll 4 dominos

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	domino_name = "Reroll"
	criteria = ["common", "sword", "top_stack"]
	
func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Reroll 1 domino's pips (1-3)"
		1, 2, 3:
			return "Reroll " + str(get_upgrade_level()) + " dominos"
		_:
			print("Error: Invalid upgrade level")
			return "Reroll 1 domino's pips (1-3)"
			
func get_detailed_description():
	var msg = get_pip_description()
	
	if (get_upgrade_level() == 1):
		msg += "Select a domino in your hand\n"
		msg += "Reroll its pips to a random value between 1 and 6"
	
	if (get_upgrade_level() >= 2):
		msg += "Select " + str(get_upgrade_level()) + " dominos in your hand\n"
		msg += "Reroll their pips to a random value between 1 and 6"

	if (get_upgrade_level() == 0):
		msg += "Select a domino in your hand\n"
		msg += "Reroll its pips to a random value between 1 and 3"
	return msg

func effect(origin, target):
	if (get_upgrade_level() == 0):
		Game.get_node("Game").domino_selection(1, 1, self, self.user, "hand", -1, "same_hand", {"reroll": [3]})
	else:
		Game.get_node("Game").domino_selection(1, get_upgrade_level(), self, self.user, "hand", -1, "same_hand", {"reroll": [6]})
	
	# Wait until the discard is complete before continuing
	yield(self, "pre_effect_complete")
	.effect(origin, target)
	
	var animation = preload("res://Battlers/Animations/Reroll.tscn")
	spell(origin, origin, 0, "spell", animation)
