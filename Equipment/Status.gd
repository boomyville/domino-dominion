extends Node2D

var game = Game.get_node("Game")
var player = game.string_to_battler("player")
var selected_index: int = -1

# Populate inventory

func initialise():
	reset()
	# Populate inventory
	for i in range(player.max_equips):
		var equipment_container = load("res://Equipment/EquipmentContainer.tscn").instance()
		if i < player.get_equipped_items().size():
			var equipment = player.get_equipped_items()[i]
			equipment_container.set_equipment_container(player, equipment)
			equipment_container.connect("equipment_pressed", self, "_on_equipment_container_pressed", [i]) # Bind the index
		else:
			equipment_container.connect("equipment_pressed", self, "_on_equipment_container_pressed", [-1]) # Bind the index

		$GridContainer.add_child(equipment_container)
		
	for i in range(player.get_inventory().size()):
		var equipment = player.get_inventory()[i]
		var equipment_container = load("res://Equipment/EquipmentContainer.tscn").instance()
		equipment_container.set_equipment_container(player, equipment)
		$GridContainer.add_child(equipment_container)
		equipment_container.connect("equipment_pressed", self, "_on_equipment_container_pressed", [player.max_equips + i]) # Bind the index
		
	$GemsText.bbcode_text = str(game.string_to_battler("player").get_gems()) + BBCode.bb_code_gem()

	# Stats display
	$CharacterStats.text = "HP: " + str (player.hp) + " / " + str(player.get_max_hp()) + "\n" + "Max shield: " + str(player.get_max_shield()) + "\n" + "Action Points: " + str(player.action_points_per_turn) + "\n" + "Draw: " + str(player.draw_per_turn) + "\n" + "Hand Size: " + str(player.max_hand_size) + "\n" + "Max Equips: " + str(player.max_equips)
		
func reset():
	for  item in $GridContainer.get_children():
		$GridContainer.remove_child(item)
	$EquipButton.hide()
		
func _on_equipment_container_pressed(index):
	selected_index = index
	if(selected_index >= 0 && selected_index < player.max_equips):
		if(game.get_game_state_string() == "Inactive"):
			$EquipButton.show()
			$EquipButton.text = "Unequip"
		$Information.text = player.get_equipped_items()[selected_index].get_description()
	elif(selected_index >= player.max_equips):
		if(game.get_game_state_string() == "Inactive"):
			$EquipButton.show()
			$EquipButton.text = "Equip"
		$Information.text = player.get_inventory()[selected_index - player.max_equips].get_description()
	else:
		$EquipButton.hide()
		$Information.text = ""
		
	for i in range($GridContainer.get_children().size()):
		if selected_index == i:
			$GridContainer.get_children()[i].selected = true
			if $GridContainer.get_children()[i].has_method("update"):
				$GridContainer.get_children()[i].update()
		else:
			$GridContainer.get_children()[i].selected = false
			if $GridContainer.get_children()[i].has_method("update"):
				$GridContainer.get_children()[i].update()
	
func _on_Button_pressed():
	game.remove_child(self.get_parent())

func _on_EquipButton_pressed():
	if(selected_index >= 0 && selected_index < player.max_equips):
		# Unequip
		if(player.get_equipped_items()[selected_index].is_cursed()):
			$Information.text = "You cannot unequip a cursed item!"
		player.unequip_item(player.get_equipped_items()[selected_index])
		selected_index = -1
		initialise()
	elif(selected_index >= 0 && selected_index >= player.max_equips):
		# Equip
		if(!player.get_inventory()[selected_index - player.max_equips].meets_requirements(player)):
			$Information.text = "You do not meet the requirements to equip this item!"
		player.equip_item(player.get_inventory()[selected_index - player.max_equips])
		selected_index = -1
		initialise()
	$EquipButton.hide()
		
		
