extends Effects

# Applies a vulnerable debuff to the attacker if defender (user) fully blocks an attack

func _init():
	event_type = "take_damage"
	name = "Spikes"

# React to the shield block event
func on_event(event_type: String, data: Dictionary) -> void:
	if event_type == "take_damage":
		data.attacker.damage(data.attacker, get_triggers())
	.on_event(event_type, data)
