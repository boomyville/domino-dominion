extends Node2D

var equipment_name
var criteria
var description
var icon
var equip_owner
var unique
var cursed 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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

func meets_requirements(battler):
	print("Checking requirements for: " + self.equipment_name, " | criteria for item: ", self.criteria, " | battler criteria: ", battler.get_criteria())
	for criterion in criteria:
		if criterion in battler.get_criteria() or criterion.to_lower() == "any":
			return true
	return false 

func init(name_param: String, criteria_param: Array, desc_param: String, icon_param, is_unique_param = false):
	equipment_name = name_param
	criteria = criteria_param
	description = desc_param
	icon = icon_param
	unique = is_unique_param

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
	return "[font=res://Fonts/VAlign.tres][img]" + self.icon + "[/img][/font] " + self.equipment_name


func get_value() -> int:
	var value = 0
	if(get_criteria().has("common")):
		value += 10
	if(get_criteria().has("uncommon")):
		value += 25
	if(get_criteria().has("rare")):
		value += 50
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

func set_name(name: String):
	self.equipment_name = name

func get_name() -> String:
	return self.equipment_name

func set_owner(new_owner):
	self.equip_owner = new_owner

func get_owner():
	return self.equip_owner

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
