extends "res://Equipment/Equipment.gd"


func initiate_equipment():
	var upgrade_suffix: String = "-" if self.get_upgrade_level() == 0 else "+".repeat(self.get_upgrade_level() - 1) if self.get_upgrade_level() > 1 else ""
	
	set_parameters({
		"set_name": "Small Bow",
		"set_criteria": ["common", "weapon", "bow"],
		"set_description": "A compact and hard to use bow. Adds 4 Clumsy Shot" + upgrade_suffix+" to the draw pile.",
		"set_icon": "res://Equipment/Icons/small_bow.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("ClumsyShot", 4, "Attack", get_upgrade_level())
	.apply_start_of_battle_effect()
