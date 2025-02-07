extends DominoContainer

# Cut the bridge
# Send all played dominos to the void space
# Downgrade - Only void last 7 dominos played
# Upgrade+ - Both pips becomes erratic

func _init():
	domino_name = "Cut The Bridge"
	criteria = ["rare", "any"]
	initiate_domino()	

func initiate_domino():
	match get_upgrade_level():
		1:
			pip_data = { "left": [1, 6, "erratic"], "right": [1, 6, "erratic"] }
		0:
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	.initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Void last 7 played dominos"
		1:
			return "Void all played dominos" 
		_:
			print("Error: Invalid upgrade level")
			return "Void last 7 played dominos"

func get_detailed_description():
	var msg = get_pip_description()
	match get_upgrade_level():
		0:
			msg += "Puts last 7 played dominos into the void space\n"
		1:
			msg += "Puts all played dominos into the void space\n"
		_:
			print("Error: Invalid upgrade level")
			msg += "Puts last 7 played dominos into the void space\n"
			
	msg += "Voided dominos are removed from the game"
	return msg

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/CutTheBridge.tscn")
	spell(origin, origin, 0, "slash", animation)

	if get_upgrade_level() == 0:
		var children = Game.get_node("Game").play_board.get_children()
		var end_index = min(7, children.size())  # Ensure we don't exceed the array length
		var result = children.slice(0, end_index)  # Slice from index 0 to end_index
		Game.get_node("Game").return_playfield_dominos(result, "VOID")
	else:
		Game.get_node("Game").return_playfield_dominos(Game.get_node("Game").play_board.get_children(), "VOID")
