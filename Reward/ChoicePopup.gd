extends CanvasLayer

var game = Game.get_node("Game")
var challenge = []

func new_challenge():
	var player = game.string_to_battler("player")
	var enemy = game.string_to_battler("enemy")
	
	var current_level = game.current_level()

	var challenges = {
		"Double Health": ["Give the enemy double health and gain an extra reward at the end of battle", "enemy", "set_max_hp", enemy.max_hp * 2],
		"Double Damage": ["Give the enemy double damage and gain an extra reward at the end of battle", "enemy", "afflict_status", "DoubleDamage", 10, 0],
		"Spikes Galore": ["Apply " + str(current_level + 5) + " Spikes to the enemy and gain an extra reward at the end of battle", "enemy", "afflict_status", "Spikes", (current_level + 5), 0],
		"Half Damage": ["Apply Impair (half damage) to self and gain an extra reward at the end of battle", "player", "afflict_status", "Impair", 10, 0],
		"Shields Up": ["Give the enemy shields equal to their maximum HP and gain an extra reward at the end of battle", "enemy", "set_fortified_shields", enemy.max_hp],
		"Nullification": ["Apply 10 Nullification (damage immunity) to the enemy and gain an extra reward at the end of battle", "enemy", "afflict_status", "Nullify", 10, 0],
		"Exploitation": ["Apply Vulnerable (50% increase to taken damage) to self and gain an extra reward at the end of battle", "player", "afflict_status", "Vulnerable", 0, 10],
		"Pyrogenic": ["Apply 10 Burn to yourself and gain an extra reward at the end of battle", "player", "afflict_status", "Burn", 10, 0],
		"Turn to Stone": ["Apply 10 Petrification to yourself and gain an extra reward at the end of battle", "player", "afflict_status", "Petrification", 10, 0],
		"Paralytic Virus": ["Become paralysed for the duration of the battle and gain an extra reward at the end of battle", "player", "afflict_status", "Paralysis", 0, -1],
		"Cryogenics": ["Become frostbitten for the duration of the battle and gain an extra reward at the end of battle", "player", "afflict_status", "Frostbite", 0, -1],
		"Provocation": ["Apply " + str(round(current_level / 3 + 6)) + " Fury to the enemy and gain an extra reward at the end of battle", "enemy", "afflict_status", "Fury", 0, round(current_level / 3 + 6)]
	}

	var keys = challenges.keys()
	var key = keys[randi() % keys.size()]
	var new_challenge = challenges[key]
	challenge = new_challenge

	$Control/PopupNode2D/Description.text = new_challenge[0]
	$Control/PopupNode2D/Title.text = key
	

func initialise():
	$Control/AnimationPlayer.play("fade_in_reward")
	
	# Add a final equipment reward
	# Based off RewardPopup method
	var all_equips = Game.get_node("Game").get_all_equipment(["any"], [])
	all_equips.shuffle()

	$Control/Node2D.set_type($Control/Node2D.reward_type.EQUIPMENT)
	$Control/Node2D.set_equipment(all_equips[0])
	$Control/Node2D.active = true

# Derived from Rewards Popup
func has_common_criteria(item_criteria: Array, battler_criteria: Array) -> bool:
	for criterion in battler_criteria:
		if item_criteria.has(criterion):
			return true  # Found a common criterion
	return false  # No common criteria

func _on_YesButton_pressed():
	var method_name = challenge[2]
	var target = Game.get_node("Game").string_to_battler(challenge[1])
	var args = challenge.slice(3, challenge.size()) #Could also use array[3:] just like python

	if target.has_method(method_name):
		
		target.callv(method_name, args)
		print("Executed method: %s on %s with args: %s" % [method_name, target, args])
	else:
		print("Method not found")

	$Control/Node2D._on_EquipmentTexture_pressed()
	$Control/Node2D.active = false
	game.post_battle_prompt()
	game.remove_child(self)

func _on_NoButton_pressed():
	game.post_battle_prompt()
	game.remove_child(self)
