extends Effects

# Prevents domino swapping numbers (flipping)

func _init():
	event_type = "draw_to_hand"
	effect_name = "Petrification"
	bb_code = BBCode.bb_code_petrify()

# React to the shield block event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "draw_to_hand":
		data.domino.set_petrification(1)
		if(get_triggers() != -1 && !simulate_damage):
			update_trigger(attached_user)
	.on_event(new_event_type, data)
