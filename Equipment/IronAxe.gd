extends "res://Equipment/Equipment.gd"

func initiate_equipment():

	var upgrade_suffix: String = "-" if self.get_upgrade_level() == 0 else "+".repeat(self.get_upgrade_level() - 1) if self.get_upgrade_level() > 1 else ""
	
	set_parameters({
		"set_name": "Iron Axe",
		"set_criteria": ["common", "weapon", "axe"],
		"set_description": "A small axe that packs a power punch. Adds 2 Wild Swing" + upgrade_suffix+" and 3 Onslaught" + upgrade_suffix + " to the draw pile.",
		"set_icon": "res://Equipment/Icons/iron_axe.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("WildSwing", 2, "Attack", get_upgrade_level())
	self.equip_owner.add_dominos_to_deck("Onslaught", 3, "Attack", get_upgrade_level())
	.apply_start_of_battle_effect()
