extends Effects

# Blocks all damage

func _init():
	event_type = "minify_damage"
	effect_name = "Nullify"
	bb_code = BBCode.bb_code_nullify()

# Override the on_event to react to damage event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "minify_damage" :
		data["damage"] *= 0  # Apply the damage multiplier
		if(get_triggers() != -1 && !simulate_damage):
			update_trigger(attached_user)
	.on_event(new_event_type, data)
