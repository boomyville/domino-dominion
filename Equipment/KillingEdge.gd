extends "res://Equipment/Equipment.gd"

func initiate_equipment():
	var upgrade_suffix: String = "-" if self.get_upgrade_level() == 0 else "+".repeat(self.get_upgrade_level() - 1) if self.get_upgrade_level() > 1 else ""
	
	set_parameters({
		"set_name": "Killing Edge",
		"set_criteria": ["uncommon", "weapon", "sword"],
		"set_description": "A deadly blade that dishes out deadly attacks. Adds 4 Onslaught" + upgrade_suffix+" and 3 Quad Strike" + upgrade_suffix+" to the draw pile." ,
		"set_icon": "res://Equipment/Icons/killing_edge.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("Onslaught", 4, "Attack", get_upgrade_level())
	self.equip_owner.add_dominos_to_deck("QuadStrike", 3, "Attack", get_upgrade_level())
	.apply_start_of_battle_effect()
