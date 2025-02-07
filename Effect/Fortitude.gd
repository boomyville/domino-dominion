extends Effects

# Only allows attacks to be played

func _init():
	event_type = "max_shield"
	effect_name = "Fortitude"
	bb_code = BBCode.bb_code_fortitude()
	#opposite_effects = ["Debilitate"]

# React to the shield block event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "max_shield":
		data["max_shield"] += get_triggers() 
		
	# No on_event(new_event_type, data) call to prevent recursion