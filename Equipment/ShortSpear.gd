extends "res://Equipment/Equipment.gd"

func initiate_equipment():

	var upgrade_suffix: String = "-" if self.get_upgrade_level() == 0 else "+".repeat(self.get_upgrade_level() - 1) if self.get_upgrade_level() > 1 else ""
	
	set_parameters({
		"set_name": "Short Spear",
		"set_criteria": ["common", "weapon", "spear"],
		"set_description": "A short spear designed for close quarters combat. Adds 4 Lunge" + upgrade_suffix+" to the draw pile.",
		"set_icon": "res://Equipment/Icons/short_spear.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("Lunge", 4, "Attack", get_upgrade_level())
	.apply_start_of_battle_effect()
