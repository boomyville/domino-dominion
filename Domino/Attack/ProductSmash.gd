extends DominoContainer

# Product Smash
# Deal damage equall to product of pips
# Downgrade - Right pip becomes [1, 3]
# Upgrade+ - Left pip becomes [1, 6]
# Upgrade++ - Left pip becomes [3, 6]
# Upgrade+++ - Both pips becomes volatile

func _init():
	domino_name = "Product Smash"
	criteria = ["common", "physical", "any"]
	action_point_cost = 2
	initiate_domino()

func get_description() -> String:
	return BBCode.bb_code_max_tile(get_numbers()) + BBCode.bb_code_multiply() + BBCode.bb_code_min_tile(get_numbers()) + BBCode.bb_code_attack() 

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal damage equal to the product of pips (" + str(get_damage_value(number_data[0]["value"] * number_data[1]["value"])) +")"
	return msg

func initiate_domino():
	match get_upgrade_level():
		0:
			pip_data["left"] = [1, 3, "erratic"]
			pip_data["right"] = [1, 3, "erratic"]
		1:
			pip_data["left"] = [1, 3, "erratic"]
			pip_data["right"] = [3, 6, "erratic"]
		2:
			pip_data["left"] = [3, 6, "erratic"]
			pip_data["right"] = [3, 6, "erratic"]
		3:
			pip_data["left"] = [3, 6, "volatile"]
			pip_data["right"] = [4, 6, "volatile"]
		_:
			print("Error: Invalid upgrade level")
			pip_data["left"] = [1, 3, "erratic"]
			pip_data["right"] = [1, 3, "erratic"]
	.initiate_domino()

func effect(origin, target):
	.effect(origin, target)
	
	var outcome = attack_message(origin, target, target.damage(origin, number_data[0]["value"] * number_data[1]["value"]))
	var animation2 = preload("res://Battlers/Animations/ProductSmash.tscn")	
	var animation = preload("res://Battlers/Animations/ChargeUp2.tscn")
	charge_smash(origin, target, outcome, animation, animation2)