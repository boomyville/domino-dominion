extends Effects

# Prevents domino swapping numbers (flipping)

func _init():
	event_type = "draw_domino"
	effect_name = "Frostbite"
	bb_code = BBCode.bb_code_frostbite()

# React to the shield block event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "draw_domino" && data.draw > 0 :
		data.draw -= 1
	.on_event(new_event_type, data)
