extends "res://Equipment/Equipment.gd"

func initiate_equipment():
	var upgrade_suffix: String = "-" if self.get_upgrade_level() == 0 else "+".repeat(self.get_upgrade_level() - 1) if self.get_upgrade_level() > 1 else ""
	
	set_parameters({
		"set_name": "Irmy Horn",
		"set_criteria": ["irmy", "weapon", "innate"],
		"set_description": "This wicked horn adorns the forehead of Irmy and is plenty sharp despite its looks. Add 8 Horn Attack" + upgrade_suffix+" to the draw pile.",
		"set_icon": "res://Equipment/Icons/irmy_horn.png",
		"set_unique": true,
		"set_cursed": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("HornAttack", 8, "Attack", get_upgrade_level())
	.apply_start_of_battle_effect()
