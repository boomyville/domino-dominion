extends Effects

# Apply damage equal to burrn stack when user attacks. Ticks down per attack. Blockable with shields

func _init():
	event_type = "on_turn_end"
	effect_name = "Burn"
	bb_code = BBCode.bb_code_burn()

# React to the shield block event
func on_event(new_event_type: String, data: Dictionary, simulate_damage: bool = false) -> void:
	if(get_triggers() <= -1):
		# No unlimited or negative burns
		attached_user.effects.erase(self)
	if new_event_type == "play_domino" && !simulate_damage:
		if("Attack" in data.domino_played.filename):
			data.user.self_damage(get_triggers(), true)
			if(get_triggers() != -1):
				update_trigger(attached_user)
	.on_event(new_event_type, data)
