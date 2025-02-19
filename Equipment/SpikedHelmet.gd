extends "res://Equipment/Equipment.gd"


func initiate_equipment():
	var upgrade_suffix: String = "-" if self.get_upgrade_level() == 0 else "+".repeat(self.get_upgrade_level() - 1) if self.get_upgrade_level() > 1 else ""
	
	set_parameters({
		"set_name": "Spiked Helmet",
		"set_criteria": ["innate", "uncommon", "enemy"],
		"set_description": "A uncomfortable helmet with a big spike on it. Adds 5 Headbonk" + upgrade_suffix+" to the draw pile",
		"set_icon": "res://Equipment/Icons/spiked_helmet.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("Headbonk", 5, "Attack", get_upgrade_level())

	.apply_start_of_battle_effect()
