extends Effects

# Applies a vulnerable debuff to the attacker if defender (user) fully blocks an attack

func _init():
	event_type = "take_damage"
	effect_name = "Spikes"
	bb_code = BBCode.bb_code_spikes()

# React to the shield block event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if new_event_type == "take_damage":
		print(data.attacker.battler_name, " took damage from spikes!")
		data.attacker.self_damage(get_triggers())
		data.attacker.damage_pose(get_triggers(), 1)
	.on_event(new_event_type, data)
