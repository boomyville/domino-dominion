extends Effects

# Applies a vulnerable debuff to the attacker if defender (user) fully blocks an attack

func _init():
    event_type = "shield_block"
    name = "Bulwark"

# React to the shield block event
func on_event(event_type: String, data: Dictionary) -> void:
    var vulnerable_buff = load("res://Effects/Vulnerable.gd").new() 
    vulnerable_buff.duration = 1
    if event_type == "shield_block":
        apply_effect(vulnerable_buff, data.attacker)
        if(get_triggers() != -1):
            update_trigger(attached_user)
    .on_event(event_type, data)
