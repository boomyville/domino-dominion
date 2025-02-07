extends Effects

# Applies double damage for the next attack

func _init():
	event_type = "magnify_damage"
	effect_name = "Impair"
	bb_code = BBCode.bb_code_impair()
	opposite_effects = ["Double Damage"]

# Override the on_event to react to damage event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "magnify_damage":
		print("Impair is minifying damage from", data["damage"], "to", round(data["damage"] * 0.5))
		data["damage"] *= 0.5  # Apply the damage multiplier
		if(get_triggers() != -1 && !simulate_damage):
			update_trigger(attached_user)
	.on_event(new_event_type, data)
