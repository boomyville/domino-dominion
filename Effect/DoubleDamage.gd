extends Effects

# Applies double damage for the next attack

func _init():
	event_type = "magnify_damage"
	effect_name = "Double Damage"
	bb_code = BBCode.bb_code_double()
	opposite_effects = ["Impair"]

# Override the on_event to react to damage event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "magnify_damage":
		print("Double Damage is magnifying damage from", data["damage"], "to", data["damage"] * 2)
		data["damage"] *= 2  # Apply the damage multiplier
		if(get_triggers() != -1 && !simulate_damage):
			update_trigger(attached_user)
	.on_event(new_event_type, data)
