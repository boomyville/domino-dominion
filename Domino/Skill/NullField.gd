extends DominoContainer

# Null Field
# Gain shields equal to dominos in void space
# Downgrade - Right pip becomes dynamic 1 - 6
# Upgrade+ - Apply 2x dominos in void space
# Upgrade++ - Select top 7 dominos and void as many as you want. Then apply shields

func _init():
	domino_name = "Null Field"
	criteria = ["uncommon", "any"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0:
			pip_data = { "left": [1, 6, "erratic"], "right": [1, 6, "dynamic"] }
		1, 2, 3:
			pip_data = { "left": [1, 6, "erratic"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [1, 6, "erratic"], "right": [1, 6, "dynamic"] }
	.initiate_domino()
	
func get_description() -> String:
	match get_upgrade_level():
		0, 1:
			return "Self: " + BBCode.bb_code_shield() + " equal to " + BBCode.bb_code_void() + " dominos"
		2:
			return "Self: " + BBCode.bb_code_shield() + " equal to " + BBCode.bb_code_double() + BBCode.bb_code_void() + " dominos"
		3:
			return BBCode.bb_code_void() + " up to 7 dominos\nSelf: " + BBCode.bb_code_shield() + " equal to " + BBCode.bb_code_double() + BBCode.bb_code_void() + " dominos"
		_:
			print("Error: Invalid upgrade level")
			return "Self: " + BBCode.bb_code_shield() + " equal to " + BBCode.bb_code_void() + " dominos"

func shield_multiplier() -> int:
	match get_upgrade_level():
		0, 1:
			return 1
		2, 3:
			return 2
		_:
			print("Error: Invalid upgrade level")
			return 1

func get_detailed_description():
	var msg = get_pip_description()
	if self.get_user() != "none":
		msg += "Self: " + str(get_shield_value(game.string_to_battler(self.get_user()).get_void_space().size() * shield_multiplier())) + " " + BBCode.bb_code_shield() + " shields\n"
	else:
		msg += "Self: " + BBCode.bb_code_shield() + " equal to the number of dominos in your void space\n"
	msg += "Shielded amount is requal to the number of dominos in your void space"
	return msg

func effect(origin, target):

	if (get_upgrade_level() == 3):
		# Select the top 7 dominos in the draw pile
		Game.get_node("Game").domino_selection(0, 7, self, self.user, "pile", 7, "void")
		# Wait until the void is complete before continuing
		yield(self, "pre_effect_complete")


	.effect(origin, target)
	var outcome = shield_message(origin, origin, origin.add_shields(origin.get_void_space().size() * shield_multiplier()))
	var animation = preload("res://Battlers/Animations/NullField.tscn")
	spell(origin, origin, outcome, "defend", animation)