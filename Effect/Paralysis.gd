extends Effects

# Prevents domino swapping numbers (flipping)

func _init():
	event_type = "after_swap"
	effect_name = "Paralysis"
	bb_code = BBCode.bb_code_paralysis()
	
# React to the shield block event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "after_swap" && data.result == "swap":
		data.result = "unplayable"
	.on_event(new_event_type, data)
