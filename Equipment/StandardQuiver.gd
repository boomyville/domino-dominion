extends "res://Equipment/Equipment.gd"


func initiate_equipment():
	var upgrade_suffix: String = "-" if self.get_upgrade_level() == 0 else "+".repeat(self.get_upgrade_level() - 1) if self.get_upgrade_level() > 1 else ""
	
	set_parameters({
		"set_name": "Standard Quiver",
		"set_criteria": ["common", "quiver", "bow"],
		"set_description": "A common holder for archers. Adds 8 Wooden Arrow" + upgrade_suffix+" to the draw pile.",
		"set_icon": "res://Equipment/Icons/standard_quiver.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("WoodenArrow", 8, "Skill")
	.apply_start_of_battle_effect()
