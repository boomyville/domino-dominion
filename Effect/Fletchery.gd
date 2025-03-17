extends Effects

# Adds a Phantom Arrow to the user's hand at the start of their turn

func _init():
	event_type = "turn_start"
	effect_name = "Fletchery"
	bb_code = BBCode.bb_code_arrow()

# React to the shield block event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) :
	if new_event_type == "turn_start":
		attached_user.add_dominos_to_hand("PhantomArrow", get_triggers(), "Skill")
	.on_event(new_event_type, data)
