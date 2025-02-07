extends Effects

# Applies 1.5x increase damage in damage received

func _init():
	event_type = "minify_damage"
	effect_name = "Vulnerable"
	bb_code = BBCode.bb_code_vulnerable()
	buff_type = "debuff"
	
# Override the on_event to react to damage event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "minify_damage":
		data.damage = round(data.damage * 1.5)  # Increase damage taken by 50%
		if(get_triggers() != -1 && !simulate_damage):
			update_trigger(attached_user)
	.on_event(new_event_type, data)