extends Effects

# Increases damage by X
# Reduces by 1 per turn

func _init():
	event_type = "modify_damage"
	effect_name = "Precision"
	bb_code = BBCode.bb_code_precision()

# Override the on_event to react to damage event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "modify_damage" :
		# Increase damage by duration
		data["damage"] += get_triggers()
		if(!simulate_damage):
			attached_user.effects.erase(self)
	.on_event(new_event_type, data)
