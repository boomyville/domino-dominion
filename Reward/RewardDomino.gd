extends Container

var reference_domino
var reference_equipment
var type
enum reward_type {DOMINO, EQUIPMENT}

var active = true
signal domino_added # A signal to indicate that a selection is made and trigger destroy() method on all reward options

func set_type(type_of_reward):
	type = type_of_reward

func set_domino(domino, upgrade_level_modifier: int = 0, over_upgrade: bool = false):
	if(type == reward_type.DOMINO):
		$DisplayNode/Node.show()
		$DisplayNode/Node2.hide()
		reference_domino = domino.shadow_copy()

		if(upgrade_level_modifier != 0):
			if(over_upgrade):
				reference_domino.upgrade_domino(upgrade_level_modifier)
			else:
				reference_domino.alter_upgrade_domino(upgrade_level_modifier)

		set_numbers(reference_domino.get_numbers()[0], reference_domino.get_numbers()[1])
		$DisplayNode/Description.bbcode_text = "[center]" + reference_domino.get_detailed_description() + "[/center]"	
		var upgrade_suffix: String = "-" if reference_domino.get_upgrade_level() == 0 else "+".repeat(reference_domino.get_upgrade_level() - 1) if reference_domino.get_upgrade_level() > 1 else ""
		
		$DisplayNode/ItemName.text = reference_domino.domino_name + upgrade_suffix
		if(reference_domino.action_point_cost > 0):
			$DisplayNode/Node/ActionPointCircle.show()
			$DisplayNode/Node/ActionPointLabel.show()
			$DisplayNode/Node/ActionPointLabel.text = str(reference_domino.action_point_cost)
		else:
			$DisplayNode/Node/ActionPointCircle.hide()
			$DisplayNode/Node/ActionPointLabel.hide()
	else:
		print("Invalid method called on domino!")

func set_equipment(equipment):
	if(type == reward_type.EQUIPMENT):
		$DisplayNode/Node.hide()
		$DisplayNode/Node2.show()
		reference_equipment = equipment 
		var icon_texture = load(equipment.get_icon())
		$DisplayNode/Node2/EquipmentTexture.texture_normal = icon_texture
		$DisplayNode/Description.bbcode_text = "[center]" + reference_equipment.get_description() + "[/center]"	
		$DisplayNode/ItemName.text = reference_equipment.get_name()
	else:
		print("Invalid method called on equipment!")

func set_numbers(number1: int, number2: int):
	if(type == reward_type.DOMINO):
		var dot_images = {
			-2: preload("res://Domino/Dots/-2_dots.png"),
			-1: preload("res://Domino/Dots/-1_dots.png"),
			0: preload("res://Domino/Dots/0_dots.png"),
			1: preload("res://Domino/Dots/1_dots.png"),
			2: preload("res://Domino/Dots/2_dots.png"),
			3: preload("res://Domino/Dots/3_dots.png"),
			4: preload("res://Domino/Dots/4_dots.png"),
			5: preload("res://Domino/Dots/5_dots.png"),
			6: preload("res://Domino/Dots/6_dots.png")
		}

		$DisplayNode/Node/LeftNumber.set_texture(dot_images[number1])
		$DisplayNode/Node/RightNumber.set_texture(dot_images[number2])
	else:
		print("Invalid method called on domino!")

func destroy():
	$AnimationPlayer.play("reward_fade_out")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func _on_TextureRect_pressed():
	if(active):
		print(reference_domino.domino_name, " added to deck")
		Game.get_node("Game").player.add_to_deck(reference_domino, "player")
		Game.get_node("Game").chosen_offered_domino(reference_domino)
		active = false
	emit_signal("domino_added")

func _on_EquipmentTexture_pressed():
	print("Active status: ",	active, " | reference equipment: ", reference_equipment.equipment_name)
	if(active):
		Game.get_node("Game").player.add_to_inventory(reference_equipment)
		active = false
	emit_signal("domino_added")
