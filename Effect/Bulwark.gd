extends Effects

# Applies a vulnerable debuff to the attacker if defender (user) fully blocks an attack

func _init():
	event_type = "full_block"
	effect_name = "Bulwark"
	bb_code = BBCode.bb_code_bulwark()

# React to the shield block event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	var vulnerable_buff = load("res://Effect/Vulnerable.gd").new() 
	vulnerable_buff.duration = 1
	if new_event_type == "full_block" && !simulate_damage:
		apply_effect(vulnerable_buff, data.attacker)
		if(get_triggers() != -1):
			update_trigger(attached_user)
	.on_event(new_event_type, data)
