extends Node2D

var equipment_name
var criteria
var description
var icon
var equip_owner
var unique
var cursed 
# Upgrade levels; start at 1 by default
var upgrade_level = 1
var max_upgrade_level = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	initiate_equipment()
	
func alter_stats() -> Dictionary:
	var new_stats = {}
	#Stats modified:
		# max_hp
		# action_points_per_turn
		# max_shield
		# max_hand_size
		# draw_per_turn
	return new_stats

func new_immunity() -> Array:
	return []

func apply_start_of_battle_effect():
	pass

func get_max_upgrade_level() -> int:
	if "common" in self.criteria or "starter" in self.criteria:
		return 4
	if "uncommon" in self.criteria:
		return 3
	if "rare" in self.criteria:
		return 2
	return 4

func upgrade_equipment(value: int = 1, over_upgrade: bool = false) -> bool:
	if can_upgrade(over_upgrade):
		if over_upgrade:
			var new_upgrade_level = min(value + upgrade_level, self.get_max_upgrade_level())
			set_upgrade_level(new_upgrade_level)
		else:
			var new_upgrade_level = min(value + upgrade_level, self.get_max_upgrade_level() - 1)
			set_upgrade_level(new_upgrade_level)
		return true
	return false

func set_upgrade_level(value: int):
	var new_upgrade_level = max(0, min(self.get_max_upgrade_level(), value))
	upgrade_level = new_upgrade_level
	initiate_equipment()

func can_upgrade(over_upgrade = false) -> bool:
	if (over_upgrade):
		return upgrade_level < get_max_upgrade_level()
	else:
		return upgrade_level < get_max_upgrade_level() - 1

func meets_requirements(battler):
	print("Checking requirements for: " + self.equipment_name, " | criteria for item: ", self.criteria, " | battler criteria: ", battler.get_criteria())
	for criterion in criteria:
		if criterion in battler.get_criteria() or criterion.to_lower() == "any":
			return true
	return false 


func set_icon(new_icon):
	self.icon = new_icon

func get_icon() -> String:
	return self.icon

func set_parameters(values: Dictionary = {}):
	for key in values.keys():
		if(has_method(key)):
			self.call(key, values[key])

func set_criteria(criteria_array: Array):
	self.criteria = criteria_array

func get_criteria() -> Array:
	return self.criteria

func set_description(string_message: String):	
	self.description = string_message

func get_description() -> String:
	return self.description

func get_equipment_name_with_bb_code():
	return "[font=res://Fonts/VAlign.tres][img]" + self.icon + "[/img][/font] " + self.get_name()

func initiate_equipment():
	pass

func get_value() -> int:
	var value = 0
	if(get_criteria().has("common")):
		value += 20
	if(get_criteria().has("uncommon")):
		value += 35
	if(get_criteria().has("rare")):
		value += 55
	if(!get_criteria().has("any")):
		value += 20
	if(self.is_cursed()):
		value = round(value * 0.5)
	if(self.is_unique()):
		value = round(value * 1.3)
	return value

func set_unique(value: bool):
	self.unique = value

func is_unique() -> bool:
	return self.unique

func set_cursed(value: bool):
	self.cursed = value

func is_cursed() -> bool:
	return self.cursed

func is_consumable() -> bool:
	return "consumable" in self.criteria

func set_name(name: String):
	self.equipment_name = name

func get_name() -> String:
	var upgrade_suffix: String = "-" if self.get_upgrade_level() == 0 else "+".repeat(self.get_upgrade_level() - 1) if self.get_upgrade_level() > 1 else ""
	return self.equipment_name + upgrade_suffix

func set_owner(new_owner):
	self.equip_owner = new_owner

func get_owner():
	return self.equip_owner

func get_upgrade_level() -> int:
	return self.upgrade_level

# ======================================================================
# Methods derived from other scenes
# ======================================================================
# Based off DominoContainerScene
func apply_effect(effect, target, value = 0):
	target.apply_effect(effect)
	var value_string = ""
	if value > 0:
		value_string = str(value)
	Game.get_node("Game").show_popup(value_string + effect.bb_code, target, "White", "PopupRiseAnimation")

func item_effect():
	pass 
