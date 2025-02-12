extends CanvasLayer

onready var rewards_container = $Node2D/HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Node2D.modulate = Color(1, 1, 1, 0)
	$Node2D/AnimationPlayer.play("fade_in")

# Create rewards
func create_rewards(enemy_domino: DominoContainer):
	
	var curated_list = Game.get_node("Game").get_domino_rewards(3)
	# 10% chance first domino is replaced by enemy domino
	if randf() > 0.10 && enemy_domino != null:
		print("Enemy domino added to rewards")
		curated_list[curated_list.size() - 1] = enemy_domino

	#Debug
		var debug_domino = load("res://Domino/Attack/ReplayAttack.tscn").instance()
		curated_list[curated_list.size() - 1] = debug_domino

	#var new_domino = load("res://Domino/Skill/NullField.tscn").instance()
	#curated_list[0] = new_domino

	for i in range(curated_list.size()):
		var reward_domino = preload("res://Reward/RewardDomino.tscn").instance()
		reward_domino.set_type(reward_domino.reward_type.DOMINO)
		reward_domino.set_domino(curated_list[i])
		rewards_container.add_child(reward_domino)
		reward_domino.connect("domino_added", self, "_on_domino_added")


	"""
	# Add a final equipment reward
	var all_equips = Game.get_node("Game").player.list_equipment_files()

	# Filter equips
	var available_equips = []
	var inventory_items = []

	# Check for items in inventory
	for items in Game.get_node("Game").player.get_inventory():
		if(items.is_unique()):
			inventory_items.append(items.get_name().replace(" ", ""))
	
	# Check equipped items
	for items in Game.get_node("Game").player.get_equipped_items():
		if(items.is_unique()):
			inventory_items.append(items.get_name().replace(" ", ""))	

	# Go through all equips and if they meet criteria and are not in inventory, add to available equips
	for equip in all_equips:
		var temp_equip_instance = load("res://Equipment/" + equip + ".tscn").instance()
		if inventory_items.find(equip) == -1 && has_common_criteria(temp_equip_instance.get_criteria(),  Game.get_node("Game").player.get_criteria()):
			available_equips.append(equip)
		temp_equip_instance.queue_free()

	print("Available equips: ", available_equips, " | inventory: ", inventory_items)

	var reward_equipment = preload("res://Reward/RewardDomino.tscn").instance()
	reward_equipment.set_type(reward_equipment.reward_type.EQUIPMENT)

	# Choose a random equip
	var equipment_path
	if(available_equips.size() > 0):
		equipment_path = "res://Equipment/" + available_equips[randi() % available_equips.size()] + ".tscn"
	else:
		equipment_path = "res://Equipment/Antimatter.tscn"
	var equipment = load(equipment_path).instance()
	reward_equipment.set_equipment(equipment)
	rewards_container.add_child(reward_equipment)
	reward_equipment.connect("domino_added", self, "_on_domino_added")	
	"""

func destroy():
	disable_all()
	$Node2D/AnimationPlayer.play("fade_out")
	yield($Node2D/AnimationPlayer, "animation_finished")
	for child in rewards_container.get_children():
		child.queue_free()
	queue_free()

func _on_Button_pressed():
	destroy()
	Game.get_node("Game").player.reset_deck()
	Game.get_node("Game").next_event()

func _on_domino_added():
	disable_all()
	for reward in rewards_container.get_children():
		reward.destroy()
	yield(get_tree().create_timer(1.0), "timeout")
	enable_all()

func _on_InventoryButton_pressed():
	var status_screen = preload("res://Equipment/Status.tscn").instance() 
	status_screen.get_node("Node2D").initialise()
	Game.get_node("Game").add_child(status_screen)
	Game.get_node("Game").set_game_state(Game.get_node("Game").GameState.INACTIVE)

func _on_DeckButton_pressed():
	var library = preload("res://Reward/Library.tscn").instance() 
	library.clear()
	library.populate_deck()
	Game.get_node("Game").add_child(library)

func disable_all():
	for child in $Node2D/HBoxContainer2.get_children():
		child.disabled = true

func enable_all():
	for child in $Node2D/HBoxContainer2.get_children():
		child.disabled = false
